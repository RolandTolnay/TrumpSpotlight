//
//  ArticleComparator.swift
//  TrumpNationBackend
//
//  Created by Roland Tolnay on 5/9/17.
//  Copyright © 2017 Agilio. All rights reserved.
//

import Foundation

protocol ArticleComparator {
    
    func isArticle(_ article: Article, identicalTo otherArticle: Article) -> Bool
}

extension ArticleComparator {
    
    func isArticle(_ article: Article, identicalTo otherArticle: Article) -> Bool {
        return article.title == otherArticle.title && article.source == otherArticle.source
    }
}

struct DefaultArticleComparator: ArticleComparator {
   
}
