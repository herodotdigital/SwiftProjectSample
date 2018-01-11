//
//  Answer.swift
//  SwiftSampleCode
//
//  Created by Adam Borek on 27.06.2016.
//  Copyright © 2016 All in Mobile. All rights reserved.
//

import Foundation
import SwiftyJSON

struct Answer: Equatable {
    let id: Int
    let textRepresentation: String
    var votesCount: Int = 0
    
    init(id: Int, textRepresentation: String, votesCount: Int) {
        self.id = id
        self.textRepresentation = textRepresentation
        self.votesCount = votesCount
    }
    
    init?(withJSON json: JSON) {
        guard let id = json["id"].int, let value = json["value"].string else { return nil }
        guard let votesCount = json["votes_count"].int else { return nil }
        self.id = id
        self.textRepresentation = value
        self.votesCount = votesCount
    }
}

extension Answer {
    mutating func vote() {
        votesCount += 1
    }
    
    mutating func unvote() {
        votesCount -= 1
    }
    
    func voted() -> Answer {
        var voted = self
        voted.votesCount += 1
        return voted
    }
    
    func unvoted() -> Answer {
        var unvoted = self
        unvoted.votesCount -= 1
        return unvoted
    }
}

func == (lhs: Answer, rhs: Answer) -> Bool {
    return lhs.id == rhs.id &&
        lhs.textRepresentation == rhs.textRepresentation
}

