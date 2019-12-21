//
//  APIService.swift
//  TrumpNation
//
//  Created by Roland Tolnay on 5/5/17.
//  Copyright © 2017 Agilio. All rights reserved.
//

import Foundation

struct APIService {
    var baseUrl: String
    
    var apiKey: String?
    var apiKeyParamName = "apiKey"
    
    /// A string representation of the API service, which can be used to make a request.
    /// It is composed of the baseUrl, and the apiKey as parameter
    var toString: String {
        guard let apiKey = apiKey else {
            return baseUrl
        }
        
        let params = UrlParameters([ apiKeyParamName : apiKey ])
        return baseUrl + params.toString!
    }
    
    init(baseUrl: String, apiKey: String) {
        self.apiKey = apiKey
        self.baseUrl = baseUrl
    }
    
    init(baseUrl: String) {
        self.baseUrl = baseUrl
    }
}
