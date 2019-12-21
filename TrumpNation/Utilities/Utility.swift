//
//  Utility.swift
//  TrumpNation
//
//  Created by Roland Tolnay on 5/11/17.
//  Copyright © 2017 Agilio. All rights reserved.
//

import UIKit

class Utility {
   
   static var rootViewController: UIViewController? {
      return UIApplication.shared.keyWindow?.rootViewController
   }
   
   static var isSmallScreen: Bool {
      let orientation = UIApplication.shared.statusBarOrientation
      if UIInterfaceOrientationIsPortrait(orientation) {
         return UIScreen.main.bounds.width <= 320
      } else {
         return UIScreen.main.bounds.height <= 320
      }
   }
   
   static var alertView: FCAlertView {
      let alert = FCAlertView()
      
      alert.cornerRadius = 2
      alert.customImageScale = 1.4
      alert.blurBackground = true
      alert.avoidCustomImageTint = true
      alert.dismissOnDonePressed = true
      
      alert.titleColor = defaultBlue
      alert.doneButtonTitleColor = defaultBlue
      alert.titleFont = UIFont(name: "Lato-Bold", size: 18)
      alert.subtitleFont = UIFont(name: "Lato-Regular", size: 16)
      alert.doneButtonFont = UIFont(name: "Lato-Bold", size: 18)
      
      return alert
   }
   
   static func openInNative(urlString: String) {
      guard let url = URL(string: urlString) else {
         return
      }
      
      UIApplication.shared.openURL(url)
   }

   static func lockOrientation(_ orientation: UIInterfaceOrientationMask, andRotateTo rotateOrientation:UIInterfaceOrientation? = nil) {
      if let delegate = UIApplication.shared.delegate as? AppDelegate {
         delegate.orientationLock = orientation
      }
      
      guard let toRotate = rotateOrientation else { return }
      UIDevice.current.setValue(toRotate.rawValue, forKey: "orientation")
   }
}
