//
//  ArticleFilterer.swift
//  TrumpNation
//
//  Created by Roland Tolnay on 5/5/17.
//  Copyright © 2017 Agilio. All rights reserved.
//

import Foundation

protocol ArticleFilterer {
    
    /// Filters articles for ones containing the specified strings
    ///
    /// - Parameters:
    ///   - articles: The articles to filter
    ///   - strings: An array of strings to filter for
    /// - Returns: An array of articles filtered for the given strings
    func filter(articles: [Article], forStrings strings:[String]) -> [Article]?
}

extension ArticleFilterer {
    
    func filter(articles: [Article], forStrings strings:[String]) -> [Article]? {
        guard !articles.isEmpty else { return nil }
        guard !strings.isEmpty else { return articles }
        
        var filteredArticles = [Article]()
        for article in articles {
            for filter in strings {
                if article.title.contains(filter) {
                    filteredArticles.append(article)
                    break
                } else if let description = article.description {
                    if description.contains(filter) {
                        filteredArticles.append(article)
                        break
                    }
                }
            }
        }
        return filteredArticles.isEmpty ? nil : filteredArticles
    }
}
