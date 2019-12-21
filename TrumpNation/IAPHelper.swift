//
//  IAPHelper.swift
//  BroadcastMe
//
//  Created by Roland Tolnay on 4/21/17.
//  Copyright © 2017 Agilio. All rights reserved.
//

import Foundation
import StoreKit

public typealias ProductId = String
public typealias ProductsRequestCompletionHandler = (_ products: [SKProduct]?, _ error: Error?) -> ()
public typealias TransactionCompletionHandler = (_ productId: ProductId?, _ error: Error?) -> ()
public typealias RestorationCompletionHandler = (_ restoredProductIds: Set<ProductId>?, _ error: Error?) -> ()

@objc class IAPHelper : NSObject {
   
   static let shared = IAPHelper()
   
   fileprivate var products = [String : SKProduct]()
   fileprivate var productIdentifiers = Set<ProductId>()
   fileprivate var purchasedProductIdentifiers = Set<ProductId>()
   
   fileprivate var receiptSharedSecret: String?
   
   fileprivate var productsRequest: SKProductsRequest?
   fileprivate var restorationQueue = [String : [SKPaymentTransaction]]()
   
   // MARK: Completion handlers
   fileprivate var productsRequestCompletionHandler: ProductsRequestCompletionHandler?
   fileprivate var buyProductCompletionHandler: TransactionCompletionHandler?
   fileprivate var restorationCompletionHandler: RestorationCompletionHandler?
   
   var productCount: Int {
      return productIdentifiers.count
   }
   
   var productsArray: [SKProduct] {
      return Array(products.values)
   }
   
   private override init() {
      super.init()
      SKPaymentQueue.default().add(self)
      let _ = IAPReceiptHelper.shared
   }
   
   class func canMakePayments() -> Bool {
      return SKPaymentQueue.canMakePayments()
   }
   
   func productFor(id: String) -> SKProduct? {
      return products[id]
   }
}

extension IAPHelper {
   
   func requestProducts(withIds productIds: Set<ProductId>, completionHandler: @escaping ProductsRequestCompletionHandler) {
      productsRequest?.cancel()
      productsRequestCompletionHandler = completionHandler
      productIdentifiers = []
      products = [String : SKProduct]()
      
      productsRequest = SKProductsRequest(productIdentifiers: productIds)
      productsRequest!.delegate = self
      productsRequest!.start()
   }
   
   func buyProduct(withId productId: ProductId, completionHandler: TransactionCompletionHandler?) {
      guard IAPHelper.canMakePayments() else {
         let error = IAPError.forbidden(message: "User is not authorized to make payments")
         completionHandler?(nil, error)
         return
      }
      guard let product = productFor(id: productId) else {
         let error = IAPError.foundNil(message: "Product id not contained in list of requested products")
         completionHandler?(nil, error)
         return
      }
      
      print("Buying \(productId)...")
      buyProductCompletionHandler = completionHandler
      let payment = SKPayment(product: product)
      SKPaymentQueue.default().add(payment)
   }
   
   /// Restores all previous purchases. In the case of subscriptions, each product id should be
   /// checked for a valid receipt.
   ///
   /// - Parameter completionHandler: The handler called once all purchases have been restored
   public func restorePurchases(completionHandler: @escaping RestorationCompletionHandler) {
      restorationCompletionHandler = completionHandler
      
      restorationQueue = [String : [SKPaymentTransaction]]()
      SKPaymentQueue.default().restoreCompletedTransactions()
   }
   
   public func isProductPurchased(withId productId: ProductId?) -> Bool {
      guard let productId = productId else { return false }
      
      return purchasedProductIdentifiers.contains(productId)
   }
   
   public func invalidateProduct(withId productId: ProductId?) {
      guard let productId = productId else { return }
      
      if purchasedProductIdentifiers.contains(productId) {
         purchasedProductIdentifiers.remove(productId)
         UserDefaults.standard.set(false, forKey: productId)
         UserDefaults.standard.synchronize()
      }
   }
}

extension IAPHelper: SKProductsRequestDelegate {
   
   public func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
      for p in response.products {
         print("Found product: \(p.productIdentifier) \(p.localizedTitle) \(p.price.floatValue)")
         productIdentifiers.insert(p.productIdentifier)
         products[p.productIdentifier] = p
         let purchased = UserDefaults.standard.bool(forKey: p.productIdentifier)
         if purchased {
            print("Previously purchased: \(p.productIdentifier)")
            purchasedProductIdentifiers.insert(p.productIdentifier)
         }
      }
      
      productsRequestCompletionHandler?(response.products, nil)
      clearRequestAndHandler()
   }
   
   public func request(_ request: SKRequest, didFailWithError error: Error) {
      print("Failed to retrieve list of products...")
      productsRequestCompletionHandler?(nil, error)
      clearRequestAndHandler()
   }
   
   private func clearRequestAndHandler() {
      productsRequest = nil
      productsRequestCompletionHandler = nil
   }
}

extension IAPHelper: SKPaymentTransactionObserver {
   
   public func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
      for transaction in transactions {
         switch (transaction.transactionState) {
         case .purchased:
            complete(transaction: transaction)
            break
         case .failed:
            fail(transaction: transaction)
            break
         case .restored:
            restore(transaction: transaction)
            break
         case .deferred:
            break
         case .purchasing:
            break
         }
      }
   }
   
   public func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
      processRestorationQueue()
   }
   
   public func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
      let error = IAPError.generic(message: error.localizedDescription)
      restorationCompletionHandler?(nil, error)
      restorationCompletionHandler = nil
   }
   
   fileprivate func addToPurchasedProducts(productId: ProductId) {
      purchasedProductIdentifiers.insert(productId)
      UserDefaults.standard.set(true, forKey: productId)
      UserDefaults.standard.synchronize()
   }
   
   private func complete(transaction: SKPaymentTransaction) {
      let productId = transaction.payment.productIdentifier
      
      print("Succesfully completed transaction for productId \(productId)")
      SKPaymentQueue.default().finishTransaction(transaction)
      
      addToPurchasedProducts(productId: productId)
      buyProductCompletionHandler?(productId, nil)
   }
   
   private func fail(transaction: SKPaymentTransaction) {
      let productId = transaction.payment.productIdentifier
      
      print("Failed transaction for productId \(productId)")
      SKPaymentQueue.default().finishTransaction(transaction)
      
      guard let error = transaction.error as NSError? else {
         let genericError = IAPError.generic(message: "Transaction failed. Please try again later.")
         buyProductCompletionHandler?(productId, genericError)
         buyProductCompletionHandler = nil
         return
      }
      guard error.code != SKError.paymentCancelled.rawValue else {
         buyProductCompletionHandler?(productId, IAPError.cancelled)
         return
      }
      
      buyProductCompletionHandler?(productId, error)
      buyProductCompletionHandler = nil
   }
   
   private func restore(transaction: SKPaymentTransaction) {
      guard let productId = transaction.original?.payment.productIdentifier else { return }
      
      print("Succesfully restored \(productId)")
      SKPaymentQueue.default().finishTransaction(transaction)
      addToRestorationQueue(transaction: transaction)
   }
   
   private func addToRestorationQueue(transaction: SKPaymentTransaction) {
      guard let productId = transaction.original?.payment.productIdentifier else { return }
      
      if var transactionsToRestore = restorationQueue[productId] {
         transactionsToRestore.append(transaction)
      } else {
         restorationQueue[productId] = [SKPaymentTransaction]()
         restorationQueue[productId]!.append(transaction)
      }
   }
   
   private func processRestorationQueue() {
      guard restorationQueue.count > 0 else {
         restorationCompletionHandler?(nil, nil)
         restorationCompletionHandler = nil
         return
      }
      
      var filteredQueue = [String : SKPaymentTransaction]();
      
      for (productId, transactions) in restorationQueue {
         var newestTransaction: SKPaymentTransaction? = nil
         
         for transaction in transactions {
            if newestTransaction == nil {
               newestTransaction = transaction
            } else {
               if let transactionDate = transaction.original?.transactionDate,
                  let newestTransactionDate = newestTransaction!.original?.transactionDate {
                  if transactionDate > newestTransactionDate {
                     newestTransaction = transaction
                  }
               }
            }
         }
         if (newestTransaction != nil) {
            filteredQueue[productId] = newestTransaction
         }
      }
      var restoredProducts = Set<ProductId>()
      for (productId, _) in filteredQueue {
         addToPurchasedProducts(productId: productId)
         restoredProducts.insert(productId)
      }
      restorationCompletionHandler?(restoredProducts.isEmpty ? nil : restoredProducts, nil)
      restorationCompletionHandler = nil
      restorationQueue = [String : [SKPaymentTransaction]]()
   }
}
