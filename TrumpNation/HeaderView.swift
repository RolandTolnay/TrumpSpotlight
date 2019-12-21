//
//  HeaderView.swift
//  TrumpNation
//
//  Created by Roland Tolnay on 23/05/2017.
//  Copyright © 2017 Agilio. All rights reserved.
//

import Foundation

class HeaderView {
   
   private static var height: CGFloat {
      return 40
   }
   
   private static var width: CGFloat {
      return (Utility.rootViewController?.view.bounds.width)!
   }
   
   static func view(for title: String) -> UIView {
      var height = self.height
      if title.isEmpty {
         height = height - 12
      }
      
      let view = UIView(frame: CGRect(x: 0, y: 0, width: width, height: height))
      view.backgroundColor = defaultBlue
      
      let titleLabel = UILabel()
      titleLabel.textColor = defaultWhite
      titleLabel.text = title
      titleLabel.font = UIFont(name: "Lato-Bold", size: 16)
      titleLabel.translatesAutoresizingMaskIntoConstraints = false
      view.addSubview(titleLabel)
      
      NSLayoutConstraint.activate([
         titleLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -8),
         titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8)
         ])
      
      return view
   }

}
