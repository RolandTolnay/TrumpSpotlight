//
//  File.swift
//  TrumpNation
//
//  Created by Roland Tolnay on 5/5/17.
//  Copyright © 2017 Agilio. All rights reserved.
//

import Foundation
import Alamofire

typealias ArticleRequestCompletionHandler = (_ articles: [Article]?, _ error: Error?) -> ()

class ArticleManager {
  
  static let shared = ArticleManager()
  
  private init() { }
  
  fileprivate let stringsToSearch = ["Donald", "Trump"];
  
  fileprivate var latestTimeStamp = Date().seconds
  fileprivate let perPage = 30
  
  static var hasNextPage = true {
    didSet {
      if !hasNextPage {
        FirLogger.newEvent(named: "articles-last-page")
      }
    }
  }
  
  func requestArticles(completion: @escaping ArticleRequestCompletionHandler) {
    fetchArticles() { articles, error in
      
      completion(articles, error)
    }
  }
  
  func requestArticlesPage(isFirst: Bool = false, completion: @escaping ArticleRequestCompletionHandler) {
    if isFirst {
      ArticleManager.hasNextPage = true
      latestTimeStamp = Date().seconds
    }
    fetchArticles(limit: perPage, endingAt: latestTimeStamp - 1) { articles, error in
      
      if var articles = articles,
        !articles.isEmpty {
        
        articles.sort() {
          return $0.publishedAtSeconds > $1.publishedAtSeconds
        }
        
        self.latestTimeStamp = articles.last!.publishedAtSeconds
        print("Updated lastTimeStamp to \(self.latestTimeStamp)")
        ArticleManager.hasNextPage = articles.count == self.perPage
        completion(articles, error)
      } else {
        ArticleManager.hasNextPage = false
        print("No articles returned")
        completion(articles, error)
      }
    }
  }
}

extension ArticleManager {
  
  /// Sends a request to retrieve articles from the database
  ///
  /// - Parameter onCompletion: The closure called when a response was received from all sources.
  ///                           Has an array of articles parameter and an error parameter.
  fileprivate func fetchArticles(completion: @escaping ArticleRequestCompletionHandler) {
    FirebaseService().readAll(from: "articles") { data, error in
      
      let response = self.articlesFromResponse(data: data, error: error)
      completion(response.articles, response.error)
    }
  }
  
  fileprivate func fetchArticles(limit: Int, endingAt: Int, completion: @escaping ArticleRequestCompletionHandler) {
    FirebaseService().readAll(from: "articles", orderBy: "publishedAtSeconds", limit: UInt(limit), endValue: UInt(endingAt)) { data, error in
      
      let response = self.articlesFromResponse(data: data, error: error)
      completion(response.articles, response.error)
    }
  }
  
  private func articlesFromResponse(data: Any?, error: Error?) -> (articles: [Article]?,error: Error?) {
    guard error == nil else {
      return (nil, error)
    }
    guard let articlesDic = data as? [String: Any] else {
      return (nil, RequestError.invalidFormat)
    }
    guard let parsedArticles = self.articles(from: articlesDic) else {
      return (nil, RequestError.invalidFormat)
    }
    
    return (parsedArticles, nil)
  }
}

extension ArticleManager: RequestHandler {
  
}

extension ArticleManager: ArticleParser {
  
  /// Creates an array of articles from a dictionary containing multiple ones and appends the source to each.
  /// Uses the article(from:) method for individual processing by default
  ///
  /// - Parameters:
  ///   - jsonResponse: The dictionary being processed
  ///   - source: The source of the articles being created
  /// - Returns: An article array containing the parsed article. Returns nil if dictionary is invalid
  func articles(from jsonResponse: Dictionary<String,Any>, source: String) -> [Article]? {
    guard let articlesDic = jsonResponse["articles"] as? [Dictionary<String, Any>] else {
      return nil
    }
    
    var articles = [Article]()
    for articleDic in articlesDic {
      if let article = article(from: articleDic) {
        var mutatingArticle = article
        mutatingArticle.source = source
        articles.append(mutatingArticle)
      }
    }
    return articles.isEmpty ? nil : articles
  }
  
  /// Custom implementation for articles processed from a database instead of an API
  func articles(from jsonResponse: Dictionary<String,Any>) -> [Article]? {
    guard !jsonResponse.isEmpty else { return nil }
    
    var articles = [Article]()
    for (_, value) in jsonResponse {
      if let articleDic = value as? [String:Any] {
        if let article = self.article(from: articleDic) {
          articles.append(article)
        }
      }
    }
    
    return articles.isEmpty ? nil : articles
  }
}

extension ArticleManager: ArticleFilterer {
  
}

extension ArticleManager: ArticleComparator {
  
  func combine(articles: inout [Article], with otherArticles: [Article]) {
    for other in otherArticles {
      var contained = false
      for article in articles {
        if isArticle(other, identicalTo: article) {
          contained = true
          print("Found duplicate article: \(other.title)")
          break
        }
      }
      if !contained {
        articles.append(other)
      }
    }
  }
}
