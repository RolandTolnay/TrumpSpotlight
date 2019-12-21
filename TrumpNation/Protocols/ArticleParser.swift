//
//  ArticleParser.swift
//  TrumpNation
//
//  Created by Roland Tolnay on 5/8/17.
//  Copyright © 2017 Agilio. All rights reserved.
//

import Foundation

protocol ArticleParser {
   
   /// Creates an array of articles from a dictionary containing multiple ones.
   /// Uses the article(from:) method for individual processing by default
   ///
   /// - Parameter jsonResponse: The dictionary being processed
   /// - Returns: An article array containing the parsed article. Returns nil if dictionary is invalid
   func articles(from jsonResponse: Dictionary<String,Any>) -> [Article]?
   
   /// Creates an article object from a dictionary
   ///
   /// - Parameter dictionary: The dictionary being processed
   /// - Returns: An article object created from the dictionary
   func article(from dictionary: Dictionary<String,Any>) -> Article?
}

extension ArticleParser {
   
   func articles(from jsonResponse: Dictionary<String,Any>) -> [Article]? {
      guard let articlesDic = jsonResponse["articles"] as? [Dictionary<String, Any>] else {
         return nil
      }
      
      var articles = [Article]()
      for articleDic in articlesDic {
         if let article = article(from: articleDic) {
            articles.append(article)
         }
      }
      return articles.isEmpty ? nil : articles
   }
   
   func article(from dictionary: Dictionary<String, Any>) -> Article? {
      guard let title = dictionary["title"] as? String else { return nil }
      guard let urlToArticle = dictionary["url"] as? String else { return nil }
      
      var article = Article(title: title, url: urlToArticle)
      article.author = dictionary["author"] as? String
      article.description = dictionary["description"] as? String
      article.publishedAt = dictionary["publishedAt"] as? String
      article.urlToImage = dictionary["urlToImage"] as? String
      article.source = dictionary["source"] as? String
      if let publishedAtSeconds = dictionary["publishedAtSeconds"] as? Int {
         article.publishedAtSeconds = publishedAtSeconds
      } else {
         article.publishedAtSeconds = Date().seconds
      }
      
      return article
   }
}
