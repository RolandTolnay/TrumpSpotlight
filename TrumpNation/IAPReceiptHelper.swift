//
//  IAPReceiptHelper.swift
//  BroadcastMe
//
//  Created by Roland Tolnay on 4/26/17.
//  Copyright © 2017 Agilio. All rights reserved.
//

import Foundation
import StoreKit

public typealias ValidReceiptsCompletionHandler = (_ validProductIds: Set<ProductId>?, _ error: Error?) -> ()

@objc class IAPReceiptHelper : NSObject {
   
   public static let shared = IAPReceiptHelper()
   
   fileprivate var receiptSharedSecret: String?
   fileprivate var validReceiptsCompletionHandler: ValidReceiptsCompletionHandler?
   
   let kReceiptExpirationKey = "expirationDate"
   let kFirSharedSecretKey = "iTunesConnectReceiptSecret"
   let kUrlStringReceiptValidation = "https://buy.itunes.apple.com/verifyReceipt"
   
   private override init() {
      super.init()
      setupReceiptSharedSecret() { sharedSecret, error in
         guard error == nil else {
            print("Error setting up receipt shared secret: \(error!.localizedDescription)")
            return
         }
         guard let sharedSecret = sharedSecret else {
            print("Shared secret returned nil with no error")
            return
         }
         
         self.receiptSharedSecret = sharedSecret
      }
   }
   
   func requestValidReceipts(completion: @escaping ValidReceiptsCompletionHandler) {
      validReceiptsCompletionHandler = completion
      
      if let receiptData = receiptData() {
         validateWithAppStore(receiptData: receiptData)
      } else {
         refreshReceipt()
      }
   }
   
   func isSubscriptionValid(withId productId:ProductId?) -> Bool {
      guard let productId = productId else { return false }
      
      let expirationDateKey = productId + kReceiptExpirationKey
      if let expirationDate = UserDefaults.standard.object(forKey: expirationDateKey) as? Date {
         return expirationDate > Date()
      }
      return false
   }
   
   /// Requests and parses receipts from Apple, and invalidates products without a valid receipt
   ///
   /// - Parameters:
   ///   - productIds: The list of product ids to validate
   ///   - completion: The handler called when validation is finished
   func validateProductIds(_ productIds: Set<ProductId>, completion:@escaping ()->()) {
      requestValidReceipts() { validProductIds, error in
         guard let validProductIds = validProductIds else {
            for productId in productIds {
               IAPHelper.shared.invalidateProduct(withId: productId)
            }
            completion()
            return
         }
         
         for productId in productIds {
            if !validProductIds.contains(productId) {
               IAPHelper.shared.invalidateProduct(withId: productId)
            }
         }
         completion()
      }
   }
}

extension IAPReceiptHelper {
   
   fileprivate func setupReceiptSharedSecret(completion: @escaping (String?, Error?) -> ()) {
      let firDb = FirebaseService()
      firDb.read(id: kFirSharedSecretKey) { data, error in
         guard error == nil else {
            completion(nil, error!)
            return
         }
         guard let secret = data as? String else {
            completion(nil, nil)
            return
         }
         
         completion(secret, nil)
      }
   }
   
   fileprivate func receiptData() -> NSData? {
      guard let receiptUrl = Bundle.main.appStoreReceiptURL else { return nil }
      guard FileManager.default.fileExists(atPath: receiptUrl.path) else { return nil }
      guard let receiptData = NSData(contentsOf: receiptUrl) else { return nil }
      
      return receiptData
   }
   
   fileprivate func refreshReceipt() {
      let request = SKReceiptRefreshRequest(receiptProperties: nil)
      request.delegate = self
      request.start()
   }
   
   fileprivate func validateWithAppStore(receiptData: NSData) {
      guard let sharedSecret = receiptSharedSecret else {
         setupReceiptSharedSecret() { sharedSecret, error in
            guard error == nil else {
               self.validReceiptsCompletionHandler?(nil, error)
               return
            }
            guard let sharedSecret = sharedSecret else {
               self.validReceiptsCompletionHandler?(nil, nil)
               return
            }
            
            self.receiptSharedSecret = sharedSecret
            self.validateWithAppStore(receiptData: receiptData, sharedSecret: sharedSecret)
         }
         return
      }
      
      validateWithAppStore(receiptData: receiptData, sharedSecret: sharedSecret)
   }
   
   private func validateWithAppStore(receiptData: NSData, sharedSecret: String) {
      let receiptDictionary = ["receipt-data" : receiptData.base64EncodedString(options: []),
                               "password" : sharedSecret] as [String : Any]
      let requestData = try? JSONSerialization.data(withJSONObject: receiptDictionary as NSDictionary, options: [])
      guard requestData != nil else {
         validReceiptsCompletionHandler?(nil, IAPError.invalidJSON)
         return
      }
      
      let storeUrl = URL(string: kUrlStringReceiptValidation)!
      var storeRequest = URLRequest(url: storeUrl as URL)
      storeRequest.httpMethod = "POST"
      storeRequest.httpBody = requestData
      
      let session = URLSession(configuration: URLSessionConfiguration.default)
      session.dataTask(with: storeRequest,
                       completionHandler: { data, response, error in
                        
                        guard error == nil else {
                           self.validReceiptsCompletionHandler?(nil, error!)
                           return
                        }
                        guard let data = data else {
                           let error = IAPError.foundNil(message: "No receipt data received from the app store")
                           self.validReceiptsCompletionHandler?(nil, error)
                           return
                        }
                        
                        let jsonResponse = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers)
                        guard jsonResponse != nil else {
                           self.validReceiptsCompletionHandler?(nil, IAPError.invalidJSON)
                           return
                        }
                        guard let receiptDictionary = jsonResponse as? NSDictionary else {
                           let error = IAPError.invalidFormat(message: "Response had invalid format. Expected dictionary.")
                           self.validReceiptsCompletionHandler?(nil, error)
                           return
                        }
                        
                        self.validateReceipts(from: receiptDictionary)
      }).resume()
   }
   
   private func validateReceipts(from receiptDictionary: NSDictionary) {
      guard let receiptInfo = receiptDictionary["latest_receipt_info"] as? NSArray else {
         let error = IAPError.invalidFormat(message: "Value had invalid format. Expected array.")
         validReceiptsCompletionHandler?(nil,error)
         return
      }
      
      var validReceiptIds = Set<ProductId>()
      for receipt in receiptInfo {
         if let receipt = receipt as? Dictionary<String, Any> {
            if isValid(receipt: receipt) {
               updateExpirationDate(for: receipt)
               if let productId = receipt["product_id"] as? ProductId {
                  validReceiptIds.insert(productId)
               }
            }
         }
      }
      
      validReceiptsCompletionHandler?(validReceiptIds.isEmpty ? nil : validReceiptIds, nil)
   }
   
   private func isValid(receipt: Dictionary<String, Any>) -> Bool {
      guard let expirationDateString = receipt["expires_date"] as? String else { return false }
      
      let formatter = DateFormatter()
      formatter.dateFormat = "yyyy-MM-dd HH:mm:ss VV"
      
      guard let expirationDate = formatter.date(from: expirationDateString) else { return false }
      
      return expirationDate > Date()
   }
   
   private func updateExpirationDate(for receipt: Dictionary<String, Any>) {
      guard let expirationDateString = receipt["expires_date"] as? String else { return }
      
      let formatter = DateFormatter()
      formatter.dateFormat = "yyyy-MM-dd HH:mm:ss VV"
      
      guard let expirationDate = formatter.date(from: expirationDateString) else { return }
      guard let productId = receipt["product_id"] as? ProductId else { return }
      
      let expirationDateKey = productId + kReceiptExpirationKey
      UserDefaults.standard.set(expirationDate, forKey: expirationDateKey)
      UserDefaults.standard.synchronize()
   }
}

extension IAPReceiptHelper: SKRequestDelegate {
   
   public func requestDidFinish(_ request: SKRequest) {
      guard let receiptData = receiptData() else {
         let error = IAPError.foundNil(message: "No receipt was found at path")
         validReceiptsCompletionHandler?(nil, error)
         return
      }
      
      validateWithAppStore(receiptData: receiptData)
   }
   
   public func request(_ request: SKRequest, didFailWithError error: Error) {
      validReceiptsCompletionHandler?(nil, error)
   }
}
