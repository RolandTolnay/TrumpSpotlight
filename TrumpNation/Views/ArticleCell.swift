//
//  ArticleCell.swift
//  TrumpNation
//
//  Created by Roland Tolnay on 5/8/17.
//  Copyright © 2017 Agilio. All rights reserved.
//

import UIKit

class ArticleCell: UITableViewCell {
   
   @IBOutlet weak var sourceImageView: UIImageView!
   @IBOutlet weak var titleLabel: UILabel!
   @IBOutlet weak var descriptionLabel: UILabel!
   @IBOutlet weak var separatorView: UIView!
   @IBOutlet weak var publishedAtLabel: UILabel!
   @IBOutlet weak var readMoreLabel: UILabel!
   
   @IBOutlet weak var titleToTop: NSLayoutConstraint!
   @IBOutlet weak var descToTitle: NSLayoutConstraint!
   @IBOutlet weak var imageToTop: NSLayoutConstraint!
   
   override func layoutSubviews() {
      super.layoutSubviews()

      separatorView.backgroundColor = defaultBlue
      titleLabel.font = UIFont(name: "Lato-Bold", size: 18)
      descriptionLabel.font = UIFont(name: "Lato-Regular", size: 14)
      publishedAtLabel.font = UIFont(name: "Lato-Light", size: 12)
      readMoreLabel.font = UIFont(name: "Roboto-Regular", size: 12)
      
//      blurImageViewEdges()
      sourceImageView.contentMode = .scaleAspectFill
      titleLabel.sizeToFit()
      
      if Utility.isSmallScreen {
         scaleToSmallScreen()
      }
   }
   
   private func scaleToSmallScreen() {
      titleLabel.font = UIFont(name: "Lato-Bold", size: 16)
      descriptionLabel.font = UIFont(name: "Lato-Regular", size: 13)
      publishedAtLabel.font = UIFont(name: "Lato-Light", size: 11)
      sourceImageView.transform = CGAffineTransform.identity
      sourceImageView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
      
      titleToTop.constant = 0
      descToTitle.constant = 6
      imageToTop.constant = -6
   }
   
   private func blurImageViewEdges() {
      let maskLayer = CAGradientLayer()
      maskLayer.frame = sourceImageView.bounds
      maskLayer.shadowRadius = 5
      maskLayer.shadowPath = CGPath(roundedRect: sourceImageView.bounds.insetBy(dx: 5, dy: 8), cornerWidth: 15, cornerHeight: 15, transform: nil)
      maskLayer.shadowOpacity = 1;
      maskLayer.shadowOffset = CGSize.zero;
      maskLayer.shadowColor = UIColor.white.cgColor
      sourceImageView.layer.mask = maskLayer;
   }
}
