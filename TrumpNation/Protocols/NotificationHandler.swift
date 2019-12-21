//
//  NotificationHandler.swift
//  TrumpNation
//
//  Created by Roland Tolnay on 5/11/17.
//  Copyright © 2017 Agilio. All rights reserved.
//

import Foundation

protocol NotificationHandler {
   
   func showNotification(from dictionary: [String:Any])
   
   func notification(from dictionary: [String:Any]) -> APNNotification?
}

extension NotificationHandler {
   
   func showNotification(from dictionary: [String:Any]) {
      guard let notification = notification(from: dictionary) else {
         return
      }
      
      showPopup(for: notification)
   }
   
   func notification(from dictionary: [String:Any]) -> APNNotification? {
      guard !dictionary.isEmpty else { return nil }
      guard let aps = dictionary[APNDicKey.content.rawValue] as? [String:Any] else { return nil }
      guard let alert = aps[APNDicKey.alert.rawValue] as? [String:Any] else { return nil }
      
      guard let body = alert[APNDicKey.body.rawValue] as? String else { return nil }
      
      var notification = APNNotification(body: body)
      notification.title = alert[APNDicKey.title.rawValue] as? String
      notification.urlString = dictionary[APNDicKey.urlString.rawValue] as? String
      
      return notification
   }
   
   private func showPopup(for notification: APNNotification) {
      let alert = Utility.alertView
      
      if let urlString = notification.urlString {
         alert.addButton("Go to Article", withActionBlock: {
            Utility.openInNative(urlString: urlString)
         })
         alert.firstButtonTitleColor = defaultRed
         alert.doneButtonFont = UIFont(name: "Lato-Regular", size: 16)
         alert.firstButtonFont = UIFont(name: "Lato-Bold", size: 16)
      }
      
      alert.showAlert(withTitle: notification.title,
                      withSubtitle: notification.body,
                      withCustomImage: UIImage(named: "logo-normal-dark"),
                      withDoneButtonTitle: "Close",
                      andButtons: nil)
   }
}

enum APNDicKey: String {
   case content = "aps"
   case alert = "alert"
   case body = "body"
   case title = "title"
   case urlString = "urlString"
}
