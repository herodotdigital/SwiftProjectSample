//
//  Comment.swift
//  SwiftSampleCode
//
//  Created by Adam Borek on 01.07.2016.
//  Copyright © 2016 All in Mobile. All rights reserved.
//

import Foundation
import SwiftyJSON

struct Comment {
    let id: Int
    let value: String
    let createdAt: Date
    let author: UserSnapshot
    
    init(id: Int, value: String, createdAt: Date, author: UserSnapshot) {
        self.id = id
        self.value = value
        self.createdAt = createdAt
        self.author = author
    }
    
    init?(withJSON json: JSON) {
        guard let id = json["id"].int,
            let value = json["value"].string,
            let date = NSDate(string: json["created_at"].string, formatString: Assembly.API.dateFormat),
            let author = MinimalUser(withJSON: json["user"])
            else { return nil }
        
        self.id = id
        self.value = value
        self.createdAt = date as Date
        self.author = author
    }
}

extension Comment: Hashable {
    var hashValue: Int {
        return id.hashValue ^ value.hashValue
    }
}

func == (lhs: Comment, rhs: Comment) -> Bool {
    return lhs.id == rhs.id
}
