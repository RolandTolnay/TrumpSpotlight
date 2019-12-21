//
//  Navigator.swift
//  TrumpNation
//
//  Created by Roland Tolnay on 17/05/2017.
//  Copyright © 2017 Agilio. All rights reserved.
//

import Foundation
import SafariServices

class Navigator: NSObject {
  
  static let shared = Navigator()
  
  private let storyboard = UIStoryboard(name: "Main", bundle: nil)
  private let root = Utility.rootViewController
  var rootNav = Utility.rootViewController?.navigationController
  
  private override init() {
    super.init()
  }
  
  // MARK: -
  // MARK: In App Purchase
  // --------------------
  func presentIAP(dismissable: Bool = true, trialState: TrialState = .ended, viewHeader: IAPViewHeader = .logo) {
    if let viewController = storyboard.instantiateViewController(withIdentifier: "IAPViewController") as? IAPViewController {
      viewController.isDismissable = dismissable
      viewController.trialState = trialState
      viewController.viewHeader = viewHeader
      root?.present(viewController, animated: true, completion: nil)
    }
    
  }
  // MARK: -
  // MARK: Safari ViewController
  // --------------------
  private var safariVc: SFSafariViewController!
  
  func presentBrowser(with url: URL) {
    safariVc = SFSafariViewController(url: url, entersReaderIfAvailable: true)
    if #available(iOS 10.0, *) {
      safariVc.preferredBarTintColor = defaultBlue
      safariVc.preferredControlTintColor = defaultWhite
    } else {
      safariVc.view.tintColor = defaultBlue
    }
    root?.present(safariVc, animated: true)
  }
  
  // MARK: -
  // MARK: Browser with HTML String
  // --------------------
  func presentBrowser(with htmlString: String, title: String) {
    if let webViewController = storyboard.instantiateViewController(withIdentifier: "webViewController") as? WebViewController {
      webViewController.htmlString = htmlString
      webViewController.textFieldTitle = title
      rootNav?.pushViewController(webViewController, animated: true)
    }
  }
  // MARK: -
  // MARK: Settings
  // --------------------
  func presentSettings() {
    let viewController = storyboard.instantiateViewController(withIdentifier: "settingsViewController")
    rootNav?.pushViewController(viewController, animated: true)
  }
  // MARK: -
  // MARK: Error Dialog
  // --------------------
  func presentDialog(for error: Error) {
    let alert = Utility.alertView
    
    var subtitle = error.localizedDescription
    if let error = error as? IAPError {
      subtitle = IAPError.message(from: error)
    }
    if let error = error as? RequestError {
      subtitle = RequestError.message(from: error)
    }
    
    alert.showAlert(withTitle: nil,
                    withSubtitle: subtitle,
                    withCustomImage: UIImage(named: "logo-normal-dark"),
                    withDoneButtonTitle: "Close",
                    andButtons: nil)
  }
}
