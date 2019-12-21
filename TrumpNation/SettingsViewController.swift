//
//  SettingsViewController.swift
//  TrumpNation
//
//  Created by Roland Tolnay on 17/05/2017.
//  Copyright © 2017 Agilio. All rights reserved.
//

import Foundation
import NVActivityIndicatorView

class SettingsViewController: UIViewController {
   
   @IBOutlet weak var tableView: UITableView!
   fileprivate var activityIndicator: NVActivityIndicatorView!
   fileprivate var blurView: UIVisualEffectView!
   
   let dataSource = SettingsMenuDataSource.shared.dataSource
   
   // MARK: -
   // MARK: Lifecycle
   // --------------------
   override func viewDidLoad() {
      super.viewDidLoad()
      
      setupTableView()
      setupLoadingIndicator()
      setupGestureRecognizers()
      self.navigationController?.navigationBar.tintColor = defaultWhite
      title = "Settings"
   }
   
   override func viewDidAppear(_ animated: Bool) {
      super.viewDidAppear(animated)
      
      FirLogger.newEvent(named: "settings-shown")
   }
   
   override func viewDidDisappear(_ animated: Bool) {
      super.viewDidDisappear(animated)
      
      FirLogger.newEvent(named: "settings-hidden")
   }
   
   private func setupTableView() {
      tableView.backgroundColor = defaultBlue
      tableView.rowHeight = 44
      
      SettingsMenuDataSource.shared.setupSections()
      SettingsMenuDataSource.shared.delegate = self
      dataSource.tableView = tableView
   }
   
   private func setupLoadingIndicator() {
      let blurEffect = UIBlurEffect(style: .dark)
      blurView = UIVisualEffectView(effect: blurEffect)
      blurView.frame = view.bounds
      blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
      view.addSubview(blurView)
      blurView.isHidden = true
      
      let indicatorSize = CGFloat(66.0)
      let x = (self.view.frame.width / 2) - (indicatorSize / 2)
      let y = (self.view.frame.height / 2) - (indicatorSize * 2)
      let frame = CGRect(x: x, y: y, width: indicatorSize, height: indicatorSize)
      activityIndicator = NVActivityIndicatorView(frame: frame, type: .ballClipRotateMultiple, color: defaultWhite)
      view.addSubview(activityIndicator)
      view.bringSubview(toFront: activityIndicator)
      activityIndicator.isHidden = true
   }
   
   private func setupGestureRecognizers() {
      let swipeBack = UISwipeGestureRecognizer(target: self, action: #selector(onSwipeBack))
      swipeBack.direction = .right
      self.view.addGestureRecognizer(swipeBack)
   }
   
   @objc private func onSwipeBack() {
      FirLogger.newEvent(named: "settings-swiped-back")
      Navigator.shared.rootNav?.popViewController(animated: true)
   }
}

extension SettingsViewController {
   
   fileprivate func startLoading() {
         self.blurView.isHidden = false
         self.activityIndicator.startAnimating()
   }
   
   fileprivate func stopLoading() {
         self.blurView.isHidden = true
         self.activityIndicator.stopAnimating()
   }
}

extension SettingsViewController: SettingsDataSourceDelegate {
   
   func didUpdateContent(of dataSource: SettingsMenuDataSource) {
      DispatchQueue.main.async {
         self.tableView.reloadData()
      }
   }
   
   func dataSource(_ dataSource: SettingsMenuDataSource, isLoading: Bool) {
      DispatchQueue.main.async {
         isLoading ? self.startLoading() : self.stopLoading()
      }
   }
}
