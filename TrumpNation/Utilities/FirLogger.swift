//
//  FirLogger.swift
//  TrumpNation
//
//  Created by Roland Tolnay on 28/05/2017.
//  Copyright © 2017 Agilio. All rights reserved.
//

import Foundation
import FirebaseAnalytics

class FirLogger {
   
   static func newEvent(named name:String, parameters: [String:Any]? = nil, context paramValue: Any? = nil) {
      #if RELEASE
         var parameters = parameters
         let name = name.replacingOccurrences(of: "-", with: "_")
         defer {
            FIRAnalytics.logEvent(withName: name, parameters: parameters)
         }
         
         formatParameters(&parameters)
         guard let paramValue = paramValue as? NSObject else { return }
         addContext(paramValue, to: &parameters)
      #endif
   }
   
   private static func addContext(_ paramValue: NSObject,to parameters: inout [String:Any]?) {
      guard parameters != nil else { return }
      
      parameters![kFIRParameterValue] = paramValue
   }
   
   private static func formatParameters(_ parameters: inout [String:Any]?) {
      guard parameters != nil else { return }
      
      for (key,value) in parameters! {
         if let value = value as? NSObject {
            parameters!.removeValue(forKey: key)
            let key = key.replacingOccurrences(of: "-", with: "_")
            parameters![key] = value
         } else {
            parameters!.removeValue(forKey: key)
         }
      }
   }
}
