//
//  UserTracker.swift
//  TrumpNation
//
//  Created by Roland Tolnay on 5/10/17.
//  Copyright © 2017 Agilio. All rights reserved.
//

import Foundation

typealias UserSignInCompletion = (_ user: User) -> ()

fileprivate let isPreviousUserKey = "isPreviousUser"

protocol UserTracker {
   
   static var isNewUser: Bool { get set }
   
   func didSignIn(user: User, completion: @escaping UserSignInCompletion)   
}

