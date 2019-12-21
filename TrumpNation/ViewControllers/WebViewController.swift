//
//  WebViewController.swift
//  TrumpNation
//
//  Created by Roland Tolnay on 5/8/17.
//  Copyright © 2017 Agilio. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: UIViewController {
   // MARK: -
   // MARK: IBOutlets
   // --------------------
   @IBOutlet weak var urlTextField: UITextField!
   @IBOutlet weak var progressView: UIProgressView!
   @IBOutlet weak var toolbar: UIToolbar!
   
   @IBOutlet weak var backButton: UIBarButtonItem!
   @IBOutlet weak var forwardButton: UIBarButtonItem!
   @IBOutlet weak var refreshButton: UIBarButtonItem!
   @IBOutlet weak var safariButton: UIBarButtonItem!
   @IBOutlet weak var shareButton: UIBarButtonItem!
   
   fileprivate var webViewHeight: NSLayoutConstraint!
   
   // MARK: -
//   var dummyStatusBar: UIView!
   fileprivate var webView: WKWebView!
   var url: URL?
   var htmlString: String?
   var textFieldTitle: String?
   
   /// Used to hide toolbar and navbar when scrolling
   fileprivate var lastOffsetY: CGFloat = 0
   
   // MARK: -
   // MARK: Lifecycle
   // --------------------
   override func viewDidLoad() {
      super.viewDidLoad()
      
      guard url != nil || htmlString != nil else {
         assertionFailure("No url specified for webview")
         dismiss()
         return
      }
      
      setupWebView()
      setupToolbar()
      UIApplication.shared.statusBarView?.backgroundColor = defaultBlue
      
      var parameters: [String:String]?
      if let url = url {
         parameters = ["url" : url.absoluteString]
         let request = URLRequest(url: url)
         webView.load(request)
      } else if let htmlString = htmlString {
         webView.loadHTMLString(htmlString, baseURL: nil)
      }
      FirLogger.newEvent(named: "webview-loaded", parameters: parameters)
   }
   
   override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
      
      setupConstraints()
   }
   
   // MARK: -
   // MARK: Setup
   // --------------------
   private func setupWebView() {
      let webConfiguration = WKWebViewConfiguration()
      webView = WKWebView(frame: .zero, configuration: webConfiguration)
      
      view.insertSubview(webView, belowSubview: progressView)
      view.bringSubview(toFront: toolbar)
      
      webView.navigationDelegate = self
      webView.scrollView.delegate = self
      
      let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.onSwipe(gesture:)))
      swipeRight.direction = .right
      swipeRight.delegate = self
      webView.addGestureRecognizer(swipeRight)
      
      webView.addObserver(self, forKeyPath: "loading", options: .new, context: nil)
      webView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
      
      urlTextField.textAlignment = .center
      urlTextField.isEnabled = false
      urlTextField.backgroundColor = UIColor(rgb: 0xecf0f1)
      if let url = url {
         urlTextField.text = url.host?.replacingOccurrences(of: "www.", with: "")
      } else {
         urlTextField.text = textFieldTitle
      }
      
//      dummyStatusBar = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 20))
//      dummyStatusBar.backgroundColor = defaultBlue
//      view.addSubview(dummyStatusBar)
//      view.bringSubview(toFront: dummyStatusBar)
      
      progressView.progressTintColor = defaultWhite
      progressView.trackTintColor = defaultBlue
   }
   
   private func setupConstraints() {
      webView.translatesAutoresizingMaskIntoConstraints = false
      webViewHeight = NSLayoutConstraint(item: webView, attribute: .height, relatedBy: .equal,
                                         toItem: view, attribute: .height, multiplier: 1, constant: 0)
      let webViewWidth = NSLayoutConstraint(item: webView, attribute: .width, relatedBy: .equal,
                                            toItem: view, attribute: .width, multiplier: 1, constant: 0)
      let webViewBottom = NSLayoutConstraint(item: webView, attribute: .bottom, relatedBy: .equal,
                                             toItem: view, attribute: .bottom, multiplier: 1, constant: 0)
      view.addConstraints([webViewHeight, webViewWidth, webViewBottom])
      
//      dummyStatusBar.translatesAutoresizingMaskIntoConstraints = false
//      let statusBarWidth = NSLayoutConstraint(item: dummyStatusBar, attribute: .width, relatedBy: .equal,
//                                              toItem: view, attribute: .width, multiplier: 1, constant: 0)
//      let statusBarTop = NSLayoutConstraint(item: dummyStatusBar, attribute: .top, relatedBy: .equal,
//                                            toItem: view, attribute: .top, multiplier: 1, constant: 0)
//      let statusBarHeight = NSLayoutConstraint(item: dummyStatusBar, attribute: .height, relatedBy: .equal,
//                                               toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 20)
//      view.addConstraints([statusBarWidth, statusBarTop, statusBarHeight])
   }
   
   private func setupToolbar() {
      backButton.isEnabled = false
      forwardButton.isEnabled = false
      
      toolbar.isTranslucent = false
      toolbar.barTintColor = defaultBlue
      
      safariButton.tintColor = defaultWhite
      refreshButton.tintColor = defaultWhite
      backButton.tintColor = defaultWhite
      forwardButton.tintColor = defaultWhite
      shareButton.tintColor = defaultWhite
   }
   
   override var prefersStatusBarHidden: Bool {
      return false
   }
   
   // MARK: -
   // MARK: Actions
   // --------------------
   @IBAction func onDoneTapped(_ sender: Any) {
      dismiss()
   }
   
   @IBAction func refresh(_ sender: Any) {
      webView.reload()
      
      FirLogger.newEvent(named: "webview-refresh")
   }
   
   // MARK: -
   
   @IBAction func goBack(_ sender: Any) {
      webView.goBack()
   }
   
   @IBAction func goForward(_ sender: Any) {
      webView.goForward()
   }
   
   @IBAction func onShareTapped(_ sender: Any) {
      guard let url = url else { return }
      
      share(url: url)
   }
   
   @IBAction func openInNative(_ sender: Any) {
      if let url = url {
         UIApplication.shared.openURL(url)
         
         FirLogger.newEvent(named: "webview-native")
      }
   }
   
   @objc private func onSwipe(gesture: UIGestureRecognizer) {
      if let swipeGesture = gesture as? UISwipeGestureRecognizer {
         switch swipeGesture.direction {
         case UISwipeGestureRecognizerDirection.right:
            dismiss()
         default:
            break
         }
      }
   }
   
   private func dismiss() {
      webView.removeObserver(self, forKeyPath: "loading")
      webView.removeObserver(self, forKeyPath: "estimatedProgress")
      self.navigationController?.setNavigationBarHidden(false, animated: true)
      self.navigationController?.popViewController(animated: true)
      
      FirLogger.newEvent(named: "webview-dismissed")
   }
   
   private func share(url: URL) {
      let activity = UIActivityViewController(activityItems: [url], applicationActivities: nil)
      activity.popoverPresentationController?.sourceView = self.view
      
      self.present(activity, animated: true, completion: nil)
   }
}
// MARK: -
// MARK: KVO
// --------------------
extension WebViewController {
   
   override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
      if (keyPath == "loading") {
         backButton.isEnabled = webView.canGoBack
         forwardButton.isEnabled = webView.canGoForward
      }
      if (keyPath == "estimatedProgress") {
         progressView.isHidden = webView.estimatedProgress == 1
         progressView.setProgress(Float(webView.estimatedProgress), animated: true)
      }
   }
}
// MARK: -
// MARK: WKNavigationDelegate
// --------------------
extension WebViewController: WKNavigationDelegate {
   
   func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
      progressView.setProgress(0.0, animated: false)
   }
}
// MARK: -
// MARK: UIScrollViewDelegate
// --------------------
extension WebViewController: UIScrollViewDelegate {
   
   func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
      lastOffsetY = scrollView.contentOffset.y
   }
   
   func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
      
      let isHidden = scrollView.contentOffset.y > self.lastOffsetY
      setNavigationBar(hidden: isHidden)
      setToolbar(hidden: isHidden)
   }
   
   private func setToolbar(hidden: Bool) {
      if hidden && !toolbar.isHidden {
         UIView.animate(withDuration: 0.3, animations: {
            self.toolbar.frame.origin.y = self.toolbar.frame.origin.y + self.toolbar.frame.height
            self.progressView.frame.origin.y = 20
            
         }, completion: { succes in
            if succes {
               self.toolbar.isHidden = true
            }
         })
      } else if toolbar.isHidden {
         toolbar.isHidden = false
         UIView.animate(withDuration: 0.3, animations: {
            self.toolbar.frame.origin.y = self.toolbar.frame.origin.y
            self.progressView.frame.origin.y = self.progressView.frame.origin.y
         })
      }
   }
   
   private func setNavigationBar(hidden: Bool) {
      webViewHeight.constant = hidden ? -20 : 0
      self.navigationController?.setNavigationBarHidden(hidden, animated: true)
   }
}
// MARK: -
// MARK: UIGestureRecognizer Delegate
// --------------------
extension WebViewController: UIGestureRecognizerDelegate {
   
   func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
      return true
   }
}
