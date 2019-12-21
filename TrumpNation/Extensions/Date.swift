//
//  Date.swift
//  TrumpNation
//
//  Created by Roland Tolnay on 5/12/17.
//  Copyright © 2017 Agilio. All rights reserved.
//

import Foundation

extension Date {
   
   var seconds: Int {
      return Int(self.timeIntervalSince1970)
   }
}
