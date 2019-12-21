//
//  Dictionary.swift
//  TrumpNation
//
//  Created by Roland Tolnay on 5/8/17.
//  Copyright © 2017 Agilio. All rights reserved.
//

import Foundation

extension Dictionary {
    
    static func += <K, V> (_ left: inout [K:V], right: [K:V]) {
        for (k, v) in right {
            left[k] = v
        } 
    }
    
    static func + <K, V> (_ left: [K:V], right: [K:V]) -> [K:V] {
        var result = left
        right.forEach{
            result[$0] = $1
        }
        return result
    }
}
