//
//  MailComposerService.swift
//  TrumpNation
//
//  Created by Roland Tolnay on 23/05/2017.
//  Copyright © 2017 Agilio. All rights reserved.
//

import Foundation
import MessageUI

class MailComposerService: NSObject {
   
   static let shared = MailComposerService()
   
   private override init() {
      super.init()
   }
   
   private var canSendMail: Bool {
      return MFMailComposeViewController.canSendMail()
   }
   
   func mailTo(_ recipients: [String], subject: String) {
      guard !recipients.isEmpty else { return }
      
      let mailComposer = MFMailComposeViewController()
      mailComposer.mailComposeDelegate = self
      
      if canSendMail {
         mailComposer.setToRecipients(recipients)
         mailComposer.setSubject(subject)
         mailComposer.setMessageBody(bodyTemplate, isHTML: false)
         
         Utility.rootViewController?.present(mailComposer, animated: true, completion: nil)
      } else {
         let recipient = recipients[0]
         let params = "subject=\(subject)&body=\(bodyTemplate)"
         let coded = "mailto:\(recipient)?\(params)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
         
         if let emailUrl = URL(string: coded!) {
            if UIApplication.shared.canOpenURL(emailUrl) {
               UIApplication.shared.openURL(emailUrl)
            }
         }
      }
   }
}

extension MailComposerService {
   
   fileprivate var bodyTemplate: String {
      return "\n\n\n\n---\nThis information is needed to help us diagnose and fix technical issues:\n\n"+"Device: \(device)\n" + "iOS Version: \(iosVersion)\n" + "App Version: \(appVersion)\n" + "UID: \(uid)"
   }
   
   private var device: String {
      return UIDevice.current.modelName
   }
   
   private var iosVersion: String {
      return UIDevice.current.systemVersion
   }
   
   private var appVersion: String {
      return Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
   }
   
   private var uid: String {
      return UserManager.userId!
   }
}

extension MailComposerService: MFMailComposeViewControllerDelegate {
   
   func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
      // Perform firebase logging based on result
      
      controller.dismiss(animated: true, completion: nil)
   }
}
