//
//  Article.swift
//  TrumpNation
//
//  Created by Roland Tolnay on 5/5/17.
//  Copyright © 2017 Agilio. All rights reserved.
//

import Foundation

struct Article {
   var title: String {
      didSet {
         title = title.trimmingCharacters(in: .whitespacesAndNewlines)
      }
   }
   var urlToArticle: String
   
   var author: String? {
      didSet {
         author = author?.trimmingCharacters(in: .whitespacesAndNewlines)
      }
   }
   
   var description: String? {
      didSet {
         description = description?.trimmingCharacters(in: .whitespacesAndNewlines)
      }
   }
   var urlToImage: String?
   var publishedAt: String?
   var publishedAtSeconds: Int!
   var source: String?
   
   init(title: String, url: String) {
      self.title = title
      self.urlToArticle = url
   }
}
