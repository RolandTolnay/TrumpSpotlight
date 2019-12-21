//
//  AppVersionValidator.swift
//  TrumpNation
//
//  Created by Roland Tolnay on 5/11/17.
//  Copyright © 2017 Agilio. All rights reserved.
//

import Foundation
import UIKit

let kAppStoreUrlString = "https://itunes.apple.com/app/broadcast-me/id491982406?mt=8"

protocol AppVersionValidator {
   
   func validateAppVersion(completion: @escaping (_ isValid: Bool)->())
   
   func restrictApp()
}

extension AppVersionValidator {
   
   func restrictApp() {
      guard let rootViewController = Utility.rootViewController else {
         assertionFailure("rootViewController was nil")
         return
      }
      
      rootViewController.view.isUserInteractionEnabled = false
      showRestrictedPopup()
   }
   
   func isVersion(_ current: String, lessThan minimum: String) -> Bool {
      let shortCurrent = shorten(versionNumber: current)
      let shortMinimum = shorten(versionNumber: minimum)
      
      return shortMinimum.compare(shortCurrent, options: .numeric) == .orderedDescending
   }
   
   private func showRestrictedPopup() {
      let alert = FCAlertView()
      
      alert.cornerRadius = 2
      alert.customImageScale = 1.3
      alert.blurBackground = true
      alert.avoidCustomImageTint = true
      alert.dismissOnDonePressed = false
      
      alert.doneActionBlock({
         Utility.openInNative(urlString: kAppStoreUrlString)
      })
      
      alert.showAlert(withTitle: "Application out of date",
                      withSubtitle: "It looks like you are using an older version of our application, which is no longer supported.\n\nIn order to enjoy the newest features and additions, we recommend updating to the latest version by visiting the App Store.",
                      withCustomImage: UIImage(named: "no-thumbnail"),
                      withDoneButtonTitle: "Get latest version",
                      andButtons: nil)
   }
   
   private func shorten(versionNumber: String) -> String {
      let unnecessarySuffix = ".0"
      var shortened = versionNumber
      
      while shortened.hasSuffix(unnecessarySuffix) {
         let index = versionNumber.index(shortened.endIndex, offsetBy: -unnecessarySuffix.length)
         shortened = shortened.substring(to: index)
      }
      
      return shortened
   }
}
