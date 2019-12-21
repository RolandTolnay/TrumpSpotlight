//
//  APNNotification.swift
//  TrumpNation
//
//  Created by Roland Tolnay on 5/11/17.
//  Copyright © 2017 Agilio. All rights reserved.
//

import Foundation

struct APNNotification {
   
   var body: String
   
   var title: String?
   var urlString: String?
   
   init(body: String) {
      self.body = body
   }
}
