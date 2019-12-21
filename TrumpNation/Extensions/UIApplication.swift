//
//  UIApplication.swift
//  TrumpNation
//
//  Created by Roland Tolnay on 5/15/17.
//  Copyright © 2017 Agilio. All rights reserved.
//

import Foundation

extension UIApplication {
   var statusBarView: UIView? {
      return value(forKey: "statusBar") as? UIView
   }
}
