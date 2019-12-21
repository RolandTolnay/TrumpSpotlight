//
//  SubscriptionHandler.swift
//  TrumpNation
//
//  Created by Roland Tolnay on 5/12/17.
//  Copyright © 2017 Agilio. All rights reserved.
//

import Foundation

typealias SubscriptionValidationHandler = (_ isValid: Bool) -> ()

protocol SubscriptionHandler {
   
   func validateSubscription(completion: @escaping SubscriptionValidationHandler)
}
