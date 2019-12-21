//
//  UIImageView.swift
//  TrumpNation
//
//  Created by Roland Tolnay on 5/8/17.
//  Copyright © 2017 Agilio. All rights reserved.
//

import UIKit

extension UIImageView {
    
    func downloadedFrom(link: String, contentMode mode: UIViewContentMode) {
        guard let url = URL(string: link) else { return }
        
        contentMode = mode
        self.layoutIfNeeded()
        
        var activityIndicator = UIActivityIndicatorView()
        let horizontalCenter = self.bounds.size.width / 2
        let verticalCenter = self.bounds.size.height / 2
        activityIndicator = UIActivityIndicatorView(frame: CGRect(x: horizontalCenter - 10, y: verticalCenter - 10, width: 20, height: 20))
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        activityIndicator.hidesWhenStopped = true
        self.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        
        URLSession.shared.dataTask(with: url, completionHandler: { (data, _, error) -> Void in
            guard
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async { () -> Void in
                self.image = image
                activityIndicator.stopAnimating()
                activityIndicator.removeFromSuperview()
            }
        }).resume()
    }

}
