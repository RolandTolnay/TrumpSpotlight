//
//  Source.swift
//  TrumpNation
//
//  Created by Roland Tolnay on 5/5/17.
//  Copyright © 2017 Agilio. All rights reserved.
//

import Foundation

struct Source {
    var id: String
    
    var name: String?
    var description: String?
    var url: String?
    
    var sortableBy: [String]?
    
    init(id: String) {
        self.id = id
    }
    
    init?(dictionary: Dictionary<String, Any>) {
        guard let id = dictionary["id"] as? String else { return nil }
        
        self.id = id
        self.name = dictionary["name"] as? String
        self.description = dictionary["description"] as? String
        self.url = dictionary["url"] as? String
        self.sortableBy = dictionary["sortsBysAvailable"] as? [String]
    }
}
