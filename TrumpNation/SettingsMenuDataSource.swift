//
//  SettingsMenuDataSource.swift
//  TrumpNation
//
//  Created by Roland Tolnay on 17/05/2017.
//  Copyright © 2017 Agilio. All rights reserved.
//

import Foundation
import Static

class SettingsMenuDataSource {
   
   static let shared = SettingsMenuDataSource()
   
   let dataSource = DataSource()
   var delegate: SettingsDataSourceDelegate?
   
   fileprivate let ourEmail = "trumpspotlight@agilio.eu"
   fileprivate let faqKey = "faq"
   fileprivate let termsOfUseKey = "termsOfUse"
   fileprivate let privacyPolicyKey = "privacyPolicy"
   
   private init() {
      setupSections()
   }
   
   func setupSections() {
      dataSource.sections = [
         accountSection(),
         supportSection(),
//         appActionsSection(),
         legalSection()
      ]
   }
}

extension SettingsMenuDataSource {
   
   private func header(for title:String) -> Section.Extremity {
      return .view(HeaderView.view(for: title))
   }
   
   // MARK: -
   // MARK: Account
   // --------------------
   fileprivate func accountSection() -> Section {
      return Section(header: header(for: "ACCOUNT"), rows: [
         Row(text: "Subscribe", selection: { [unowned self] in
            guard SubscriptionManager.isSubscribed == false else {
               self.setupSections()
               return
            }
            let trialState = SubscriptionManager.trialState
            Navigator.shared.presentIAP(dismissable: true, trialState: trialState)
         }, cellClass:SettingsCell.self, context: ["enabled": !SubscriptionManager.isSubscribed]),
         Row(text: "Restore Purchases", selection: {
            self.restorePurchases()
         }, cellClass:SettingsCell.self)
         ])
   }
   
   private func restorePurchases() {
      delegate?.dataSource(self, isLoading: true)
      
      logSettingsEvent(named: "purchase-restore-start")
      IAPHelper.shared.restorePurchases() { [unowned self] productIds, error in
         guard error == nil else {
            self.delegate?.dataSource(self, isLoading: false)
            Navigator.shared.presentDialog(for: error!)
            
            if let error = error as? IAPError {
               self.logSettingsEvent(named: "purchase-restore-error", message: IAPError.message(from: error))
            } else {
               self.logSettingsEvent(named: "purchase-restore-error", message: error!.localizedDescription)
            }
            return
         }
         guard let productIds = productIds else {
            self.delegate?.dataSource(self, isLoading: false)
            self.logSettingsEvent(named: "purchase-restore-nothing")
            return
         }
         
         IAPReceiptHelper.shared.validateProductIds(productIds) { [unowned self] in
            self.delegate?.dataSource(self, isLoading: false)
            
            for productId in productIds {
               if IAPHelper.shared.isProductPurchased(withId: productId) {
                  guard productId == SubscriptionManager.subscriptionProductId else { return }
                  
                  SubscriptionManager.isSubscribed = true
                  self.delegate?.didUpdateContent(of: self)
                  self.logSettingsEvent(named: "purhcase-restore-succes")
               }
            }
         }
      }
   }
   
   // MARK: -
   // MARK: Support
   // --------------------
   fileprivate func supportSection() -> Section {
      return Section(header: header(for: "SUPPORT"), rows: [
         Row(text: "Report a Bug", selection: {
            self.reportBug()
         }, cellClass:SettingsCell.self),
         Row(text: "Contact Us", selection: {
            self.contactUs()
         }, cellClass:SettingsCell.self),
         Row(text: "Frequently Asked Questions", selection: {
            self.faq()
         }, accessory: .disclosureIndicator, cellClass: SettingsCell.self)
         ])
   }
   
   private func reportBug() {
      FirLogger.newEvent(named: "report-bug")
      MailComposerService.shared.mailTo([ ourEmail ], subject: "Report a Bug")
   }
   
   private func contactUs() {
      FirLogger.newEvent(named: "contact-us")
      MailComposerService.shared.mailTo([ ourEmail ], subject: "Contact Us")
   }
   
   private func faq() {
      delegate?.dataSource(self, isLoading: true)
      
      let firebase = FirebaseService()
      firebase.read(id: faqKey) { data, error in
         self.delegate?.dataSource(self, isLoading: false)
         
         guard error == nil else { return }
         guard let htmlString = data as? String else { return }
         
         Navigator.shared.presentBrowser(with: htmlString, title: "Frequently Asked Questions")
         FirLogger.newEvent(named: "faq")
      }
   }
   
   // MARK: -
   // MARK: App Actions
   // --------------------
   fileprivate func appActionsSection() -> Section {
      return Section(header: header(for: ""), rows: [
         Row(text: "Review on the App Store", selection: {
            self.review()
         }, cellClass:SettingsCell.self),
         Row(text: "Share Trump Spotlight", selection: {
            self.shareApp()
         }, cellClass:SettingsCell.self)
         ])
   }
   
   private func review() {
      
   }
   
   private func shareApp() {
      
   }
   
   // MARK: -
   // MARK: Legal
   // --------------------
   fileprivate func legalSection() -> Section {
      return Section(header: header(for: ""), rows: [
         Row(text: "Terms of Use", selection: {
            self.termsOfUse()
         }, accessory: .disclosureIndicator, cellClass:SettingsCell.self),
         Row(text: "Privacy Policy", selection: {
            self.privacyPolicy()
         }, accessory: .disclosureIndicator, cellClass:SettingsCell.self)
//         Row(text: "Legal", selection: {
//            self.legal()
//         }, accessory: .disclosureIndicator, cellClass:SettingsCell.self)
         ], footer: .title("Powered by newsapi.org"))
   }
   
   private func termsOfUse() {
      delegate?.dataSource(self, isLoading: true)
      
      let firebase = FirebaseService()
      firebase.read(id: termsOfUseKey) { data, error in
         self.delegate?.dataSource(self, isLoading: false)
         
         guard error == nil else { return }
         guard let htmlString = data as? String else { return }
         
         Navigator.shared.presentBrowser(with: htmlString, title: "Terms of Use")
         FirLogger.newEvent(named: "terms-of-use")
      }
   }
   
   private func privacyPolicy() {
      delegate?.dataSource(self, isLoading: true)
      
      FirebaseService().read(id: privacyPolicyKey) { data, error in
         self.delegate?.dataSource(self, isLoading: false)
         
         guard error == nil else { return }
         guard let htmlString = data as? String else { return }
         
         Navigator.shared.presentBrowser(with: htmlString, title: "Privacy Policy")
         FirLogger.newEvent(named: "privacy-policy")
      }
   }
   
   private func legal() {
      
   }
}

extension SettingsMenuDataSource {
   
   fileprivate func logSettingsEvent(named name: String, message: String? = nil) {
      let trialState = SubscriptionManager.trialState.rawValue
      let remainingDays = SubscriptionManager.remainingTrialDays
      FirLogger.newEvent(named: name,
                         parameters: ["trial-state":trialState,
                                      "remaining-trial": remainingDays,
                                      "message": message ?? ""])
   }
}
