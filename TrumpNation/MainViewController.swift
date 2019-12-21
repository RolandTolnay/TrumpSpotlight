//
//  MainViewController.swift
//  TrumpNation
//
//  Created by Roland Tolnay on 5/5/17.
//  Copyright © 2017 Agilio. All rights reserved.
//

import UIKit
import Nuke
import NVActivityIndicatorView
import PullToRefreshSwift
import FirebaseAuth


let defaultBlue = UIColor(rgb: 0x002868)
let defaultRed = UIColor(rgb: 0xBF0A30)
let defaultWhite = UIColor.white

class MainViewController: UIViewController {
  
  // MARK: -
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var iapContainer: UIView!
  @IBOutlet weak var blurView: UIVisualEffectView!
  fileprivate var iapModal: IAPViewController!
  
  fileprivate var activityIndicator: NVActivityIndicatorView!
  
  // MARK: -
  fileprivate let articleManager = ArticleManager.shared
  fileprivate let userManager = UserManager()
  
  fileprivate var articles = [Article]()
  fileprivate let fetchThreshold = 8
  
  fileprivate var openArticleExternally = false
  
  // MARK: -
  @IBOutlet weak var iapContainerTop: NSLayoutConstraint!
  @IBOutlet weak var iapContainerBottom: NSLayoutConstraint!
  
  // MARK: -
  // MARK: Lifecycle
  // --------------------
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupMain()
    setupTableView()
    setupLoadingIndicator()
    setupIapContainer()
    
    startLoading()
    authenticate()
    
    navigationController?.navigationBar.barTintColor = defaultBlue
    navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    if SubscriptionManager.isSubscribed || SubscriptionManager.isTrial {
      unlockForSubscription()
    }
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    if !SubscriptionManager.isSubscribed && !SubscriptionManager.isTrial {
      lockForSubscription()
    }
  }
  
  // MARK: -
  private func authenticate() {
    // Sign in with Firebase
    FIRAuth.auth()?.signInAnonymously() { user, error in
      guard error == nil,
        let user = user else {
          // Stuck in infinite loading
          assertionFailure(error!.localizedDescription)
          return
      }
      FirebaseService().read(id: "openArticleExternally") { data, error in
        guard error == nil,
          let openExternally = data as? Int else { return }
        
        self.openArticleExternally = openExternally == 0 ? false : true
      }
      
      // Check for user in database
      UserManager().didSignIn(user: FirebaseService.userFrom(user)) { user in
        if user.trialStartedSeconds != nil {
          // Check for subscription/trial state
          SubscriptionManager().validateSubscription() { isValid in
            if !isValid {
              // User doesn't have valid trial or subscription
              DispatchQueue.main.async {
                self.lockForSubscription()
              }
            }
          }
        } else {
          // Trial never started
          DispatchQueue.main.async {
            Navigator.shared.presentIAP(dismissable: false, trialState: .notStarted)
          }
        }
      }
      
      // Grab latest articles from database
      self.refreshData(onFinish: {
        DispatchQueue.main.async {
          self.stopLoading()
        }
      })
      
      // Check if using newest app version from database
      let validator = FirAppVersionValidator()
      validator.validateAppVersion() { isValid in
        if !isValid {
          DispatchQueue.main.async {
            validator.restrictApp()
          }
        }
      }
    }
  }
  
  // MARK: -
  // MARK: Actions
  // --------------------
  @IBAction func onQuestionMarkTapped(_ sender: Any) {
    Navigator.shared.presentSettings()
  }
  
  // MARK: -
  // MARK: Setup
  // --------------------
  private func setupMain() {
    let logoImageView = UIImageView(image: UIImage(named: "logo-small"))
    self.navigationItem.titleView = logoImageView
    self.navigationController?.navigationBar.backgroundColor = defaultBlue
    self.navigationController?.navigationBar.isTranslucent = false
    
    self.view.backgroundColor = defaultBlue
    Navigator.shared.rootNav = self.navigationController
  }
  
  private func setupTableView() {
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.estimatedRowHeight = 200
    tableView.delegate = self
    tableView.dataSource = self
    
    tableView.backgroundColor = defaultBlue
    
    var options = PullToRefreshOption()
    options.indicatorColor = defaultWhite
    tableView.addPullRefresh(options: options) { [weak self] in
      self?.refreshData {
        self?.tableView.stopPullRefreshEver()
      }
    }
  }
  
  private func setupLoadingIndicator() {
    let indicatorSize = CGFloat(66.0)
    let x = (self.view.frame.width / 2) - (indicatorSize / 2)
    let y = (self.view.frame.height / 2) - (indicatorSize * 2)
    let frame = CGRect(x: x, y: y, width: indicatorSize, height: indicatorSize)
    activityIndicator = NVActivityIndicatorView(frame: frame, type: .ballClipRotateMultiple, color: defaultWhite)
    view.addSubview(activityIndicator)
  }
  
  private func setupIapContainer() {
    iapContainer.alpha = 0
    iapContainer.layer.masksToBounds = false
    iapContainer.layer.shadowColor = UIColor.black.cgColor
    iapContainer.layer.shadowOffset = CGSize(width: 1, height: 1)
    iapContainer.layer.shadowOpacity = 0.8
    iapContainer.layer.shadowRadius = 3
    blurView.alpha = 0
    
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "iapEmbedSegue" {
      guard let iapModal = segue.destination as? IAPViewController else { return }
      self.iapModal = iapModal
      
      iapModal.delegate = self
      iapModal.isDismissable = false
      iapModal.viewHeader = .label
    }
  }
  
  override var prefersStatusBarHidden: Bool {
    return false
  }
  
  // MARK: -
  private func refreshData(onFinish: @escaping ()->()) {
    FirLogger.newEvent(named: "articles-refreshed")
    let requestStart = Date()
    articleManager.requestArticlesPage(isFirst: true) { articles, error in
      guard let articles = articles else {
        onFinish()
        return
      }
      
      self.articles = articles
      //         self.articles.sort() {
      //            return $0.publishedAtSeconds > $1.publishedAtSeconds
      //         }
      DispatchQueue.main.async {
        self.tableView.reloadData()
        self.tableView.animateCells(animation: TableViewAnimation.Cell.fade(duration: 0.6))
      }
      
      onFinish()
      let requestFinish = Date()
      let time = requestFinish.timeIntervalSince(requestStart)
      print("Fetched \(articles.count) articles in \(time) seconds")
    }
  }
}

extension MainViewController {
  
  fileprivate func startLoading() {
    self.tableView.isHidden = true
    self.activityIndicator.startAnimating()
  }
  
  fileprivate func stopLoading() {
    self.tableView.isHidden = false
    self.activityIndicator.stopAnimating()
  }
  
  fileprivate func lockForSubscription() {
    guard iapContainer.alpha != 1 else { return }
    
    FirLogger.newEvent(named: "articles-locked")
    iapModal.setupProductPrice()
    UIView.animate(withDuration: 0.3) {
      self.blurView.alpha = 0.95
      self.iapContainer.alpha = 1
    }
  }
  
  fileprivate func unlockForSubscription() {
    guard iapContainer.alpha != 0 else { return }
    
    FirLogger.newEvent(named: "articles-unlocked")
    UIView.animate(withDuration: 0.3) {
      self.blurView.alpha = 0
      self.iapContainer.alpha = 0
    }
  }
}
// MARK: -
// MARK: UITableViewDataSource
// --------------------
extension MainViewController: UITableViewDataSource {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return articles.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let reuseIdentifier = "articleCell"
    let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! ArticleCell
    
    let article = articles[indexPath.row]
    cell.titleLabel.text = article.title
    cell.descriptionLabel.text = article.description ?? ""
    cell.publishedAtLabel.text = shortTimestamp(from: article.publishedAt) ?? ""
    
    if let articleUrl = URL(string: article.urlToArticle),
      let articleHost = articleUrl.host {
      cell.readMoreLabel.isHidden = false
      let shortened = articleHost.replacingOccurrences(of: "www.", with: "")
      cell.readMoreLabel.text = shortened
    } else {
      cell.readMoreLabel.isHidden = true
    }
    
    cell.sourceImageView.image = UIImage(named: "logo-placeholder")
    if let urlString = article.urlToImage, let url = URL(string: urlString) {
      Nuke.loadImage(with: url, into: cell.sourceImageView)
    }
    //      if let source = article.source, let image = UIImage(named: source) {
    //         cell.sourceImageView.image = image
    //      }
    
    return cell
  }
  
  func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    if (articles.count - indexPath.row) == fetchThreshold && ArticleManager.hasNextPage {
      articleManager.requestArticlesPage() { articles, error in
        // Check if no articles returned, then no more to fetch
        
        guard let articles = articles else {
          print("No new articles fetched")
          return
        }
        print("Fetched \(articles.count) more articles")
        
        self.articleManager.combine(articles: &self.articles, with: articles)
        self.articles.sort() {
          return $0.publishedAtSeconds > $1.publishedAtSeconds
        }
        DispatchQueue.main.async {
          self.tableView.reloadData()
        }
      }
    }
  }
  
  private func shortTimestamp(from timestamp: String?) -> String? {
    guard let timestamp = timestamp else { return nil }
    
    let parts = timestamp.components(separatedBy: "T")
    guard !parts.isEmpty else { return nil }
    
    return parts[0]
  }
}
// MARK: -
// MARK: UITableViewDelegate
// --------------------
extension MainViewController: UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let article = articles[indexPath.row]
    
    if let url = URL(string: article.urlToArticle) {
      if openArticleExternally {
        Utility.openInNative(urlString: url.absoluteString)
      } else {
        Navigator.shared.presentBrowser(with: url)
      }
      
      let event = "opened-\(article.source ?? "unknown-source")"
      FirLogger.newEvent(named: event, parameters: ["title":article.title,
                                                    "url":article.urlToArticle])
    }
    tableView.deselectRow(at: indexPath, animated: true)
  }
}


extension MainViewController: IAPViewControllerDelegate {
  
  func iapViewController(_ viewController: IAPViewController, didUnlock productId: ProductId) {
    guard productId == SubscriptionManager.subscriptionProductId else { return }
    
    DispatchQueue.main.async {
      self.unlockForSubscription()
    }
  }
}
