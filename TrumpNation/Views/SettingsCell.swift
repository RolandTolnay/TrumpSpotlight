//
//  SettingsCell.swift
//  TrumpNation
//
//  Created by Roland Tolnay on 23/05/2017.
//  Copyright © 2017 Agilio. All rights reserved.
//

import UIKit
import Static

class SettingsCell: UITableViewCell {
   
   
   @IBOutlet weak var cellTextLabel: UILabel!
   
   override func layoutSubviews() {
      super.layoutSubviews()
      
      cellTextLabel.font = UIFont(name: "Lato-Regular", size: 16)
   }
}

extension SettingsCell: Cell {
   
   func configure(row: Row) {
      cellTextLabel.text = row.text
      accessoryType = row.accessory.type
      accessoryView = row.accessory.view
      
      if let context = row.context {
         let enabled = context["enabled"] as! Bool
         cellTextLabel.textColor = enabled ? UIColor.black : UIColor.lightGray
      }
   }
   
   static func nib() -> UINib? {
      return UINib(nibName: String(describing: self), bundle: nil)
   }
}
