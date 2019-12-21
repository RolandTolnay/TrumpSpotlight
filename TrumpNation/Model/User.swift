//
//  User.swift
//  TrumpNation
//
//  Created by Roland Tolnay on 5/10/17.
//  Copyright © 2017 Agilio. All rights reserved.
//

import Foundation

struct User {
   
   var uid: String
   
   var firstLoginSeconds: Int?
   var trialStartedSeconds: Int?
   
   init(uid: String) {
      self.uid = uid
      firstLoginSeconds = nil
      trialStartedSeconds = nil
   }
}
