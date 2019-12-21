//
//  Errors.swift
//  TrumpNation
//
//  Created by Roland Tolnay on 5/5/17.
//  Copyright © 2017 Agilio. All rights reserved.
//

import Foundation

enum RequestError: Error {
   
   /// An invalid response was returned from an external source
   case invalidResponse(code: String, message: String)
   
   /// A source being processed was in unexpected format
   case invalidFormat
   
   static func message(from error: RequestError) -> String {
      switch error {
      case .invalidResponse(code: let code, message: let message):
         return "\(message) - \(code)"
      case .invalidFormat:
         return "Returned data was in unexpected format"
      }
   }
}

public enum IAPError: Error, Equatable {
   
   case invalidFormat(message: String)
   case invalidJSON
   case foundNil(message: String)
   case forbidden(message: String)
   case cancelled
   case generic(message: String)
   
   static func message(from error: IAPError) -> String {
      switch error {
      case .invalidFormat(message: let message):
         return message
      case .invalidJSON:
         return "Unable to parse json"
      case .foundNil(message: let message):
         return message
      case .forbidden(message: let message):
         return message
      case .cancelled:
         return "Purchase cancelled by user"
      case .generic(message: let message):
         return message
      }
   }
}

public func ==(lhs: IAPError, rhs: IAPError) -> Bool {
   return IAPError.message(from: lhs) == IAPError.message(from: rhs)
}

// When adding new error types remember to add handling in Navigator.presentDialog(for error:Error)
