//
//  SubscriptionManager.swift
//  TrumpNation
//
//  Created by Roland Tolnay on 5/12/17.
//  Copyright © 2017 Agilio. All rights reserved.
//

import Foundation
import StoreKit

struct SubscriptionManager: SubscriptionHandler {
   
   private let firDb = FirebaseService()
   
   static let subscriptionProductId = "com.rv.trump.basicsubscription"
   
   static var isSubscribed = false
   static var isTrial = true
   
   static var remainingTrialDays = 3
   
   static var trialState: TrialState {
      if UserManager.isNewUser {
         return .notStarted
      }
      return remainingTrialDays > 0 ? .inProgress : .ended
   }
   
   func startedTrial(for user: inout User) {
      UserManager.isNewUser = false
      user.trialStartedSeconds = Date().seconds
      UserManager().saveUser(user)
      
      FirLogger.newEvent(named: "trial-started")
   }
   
   func validateSubscription(completion: @escaping (Bool) -> ()) {
      firDb.read(id: "trialSeconds") { data, error in
         guard error == nil else {
            print("ERROR: \(error!.localizedDescription)")
            completion(true)
            return
         }
         guard let trialSeconds = data as? Int else {
            print("Cant read trialSeconds as Int")
            completion(true)
            return
         }
         self.validateTrial(with: trialSeconds) { trialState in
            switch trialState {
            case .notStarted, .inProgress:
               completion(true)
               SubscriptionManager.isTrial = true
               print("Has valid trial: true")
            case .ended:
               print("Has valid trial: false")
               SubscriptionManager.isTrial = false
               self.validatePurchase() { isValid in
                  print("Has valid purchase: \(isValid)")
                  SubscriptionManager.isSubscribed = isValid
                  completion(isValid)
               }
            }
         }
      }
   }
   
   func priceText(for productId: String) -> String? {
      guard let product = IAPHelper.shared.productFor(id: productId) else {
         return nil
      }
      
      let formatter = NumberFormatter()
      formatter.formatterBehavior = .behavior10_4
      formatter.numberStyle = .currency
      formatter.locale = product.priceLocale
      
      return formatter.string(from: product.price)
   }
   
   func setupTrialDays(completion: @escaping ()->()) {
      firDb.read(id: "trialSeconds") { data, error in
         defer { completion() }
         guard let trialSeconds = data as? Int else { return }
         
         let trialPeriod = Date().seconds + trialSeconds
         SubscriptionManager.remainingTrialDays = self.trialDays(from: trialPeriod)
      }
   }
   
   private func validateTrial(with trialSeconds: Int, completion: @escaping (TrialState) -> ()) {
      let userId = UserManager.userId!
      firDb.read(from: "users", id: userId) { data, error in
         guard error == nil,
            let user = data as? [String:Any],
            let trialStarted = user["trialStarted"] as? Int else {
               completion(.notStarted)
               return
         }
         
         let trialPeriod = trialStarted + trialSeconds
         SubscriptionManager.remainingTrialDays = self.trialDays(from: trialPeriod)
         let now = Date().seconds
         let trialState: TrialState = trialPeriod >= now ? .inProgress : .ended
         completion(trialState)
      }
   }
   
   private func trialDays(from trialPeriod: Int) -> Int {
      let now = Date().seconds
      guard trialPeriod > now else { return 0 }
      
      let daySeconds = 86400.0
      let remainingTrial = Double(trialPeriod - now)
      
      return Int(ceil(remainingTrial / daySeconds))
   }
   
   private func validatePurchase(completion: @escaping (Bool) -> ()) {
      let productIds: Set<ProductId> = [SubscriptionManager.subscriptionProductId]
      IAPHelper.shared.requestProducts(withIds: productIds) { products, error in
         IAPReceiptHelper.shared.requestValidReceipts() { productIds, error in
            guard error == nil else {
               print("ERROR validating purchase: \(error!.localizedDescription)")
               completion(false)
               return
            }
            guard let productIds = productIds else {
               completion(false)
               return
            }
            
            // This is application specific
            // Generalize if more in app purchases are implemented
            completion(productIds.contains(SubscriptionManager.subscriptionProductId))
         }
      }
   }
   
   private func validateFromUserDefaults() -> (isTrial: Bool, isSubscribed: Bool) {
      let isTrial = UserDefaults.standard.bool(forKey: "isTrial")
      let isSubscribed = UserDefaults.standard.bool(forKey: "isSubscribed")
      return (isTrial, isSubscribed)
   }
}
