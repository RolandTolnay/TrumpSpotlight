//
//  FirAppVersionValidator.swift
//  TrumpNation
//
//  Created by Roland Tolnay on 5/11/17.
//  Copyright © 2017 Agilio. All rights reserved.
//

import Foundation

struct FirAppVersionValidator {
   
   fileprivate let firebase = FirebaseService()
   
   fileprivate let minVersionKey = "minimumAppVersion"
}

extension FirAppVersionValidator: AppVersionValidator {
   
   func validateAppVersion(completion: @escaping (_ isValid: Bool)->()) {
      let current = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
      requestMinVersion() { minimum, error in
         guard error == nil else {
            completion(true)
            print(error!.localizedDescription)
            return
         }
         guard let minimum = minimum else {
            completion(true)
            return
         }
         
         let isValidVersion = !self.isVersion(current, lessThan: minimum)
         completion(isValidVersion)
      }
   }
   
   private func requestMinVersion(completion: @escaping (_ minVersion: String?, _ error: Error?) -> ()) {
      firebase.read(id: minVersionKey) { data, error in
         guard error == nil else {
            completion(nil, error!)
            return
         }
      
         if let minVersion = data as? String {
            completion(minVersion, nil)
         } else {
            completion(nil, nil)
         }
      }
   }
}
