//
//  Request.swift
//  TrumpNation
//
//  Created by Roland Tolnay on 5/8/17.
//  Copyright © 2017 Agilio. All rights reserved.
//

import Foundation

struct Request {
    
    /// The API service where the request will be made
    var apiService: APIService
    
    /// Extra path components used after the API service baseUrl
    var pathComponents: String?
    
    /// Extra parameters passed to the request
    var parameters: UrlParameters?
    
    /// A string representation of the request which can be sent for processing
    var toString: String {
        let baseUrl = apiService.baseUrl
        let pathComponents = self.pathComponents ?? ""
        var params = UrlParameters([String: String]())
        if let apiKey = apiService.apiKey {
            params += UrlParameters([ apiService.apiKeyParamName : apiKey ])
        }
        if let parameters = parameters {
            params += parameters
        }
        
        return baseUrl + pathComponents + (params.toString ?? "")
    }
    
    init(apiService: APIService) {
        self.apiService = apiService
    }
}
