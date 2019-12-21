//
//  UrlParameters.swift
//  TrumpNation
//
//  Created by Roland Tolnay on 5/5/17.
//  Copyright © 2017 Agilio. All rights reserved.
//

import Foundation

struct UrlParameters {
    private(set) var params: Dictionary<String, String>
    
    /// A string representation of the parameters which can be appended to an URL
    var toString: String? {
        guard !params.isEmpty else { return nil }
        
        var paramString = "?"
        for (key, value) in params {
            if paramString != "?" {
                paramString += "&"
            }
            paramString += "\(key)=\(value)"
        }
        return paramString
    }
    
    init(_ parameters: Dictionary<String, String>) {
        self.params = parameters
    }
}

extension UrlParameters {
    
    static func += (_ left: inout UrlParameters, right: UrlParameters) {
        var params = left.params
        for (key,value) in right.params {
            params[key] = value
        }
        left = UrlParameters(params)
    }
}
