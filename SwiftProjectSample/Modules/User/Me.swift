//
//  User.swift
//  SwiftSampleCode
//
//  Created by Adam Borek on 13.05.2016.
//  Copyright © 2016 All in Mobile. All rights reserved.
//

import Foundation

struct Me: UserSnapshot, Equatable {
    fileprivate (set) var id: Int
    fileprivate (set) var username: String
    fileprivate (set) var realname: String?
    fileprivate (set) var avatarURL: URL?

    init(id: Int, username: String, realname: String? = nil, avatarURL: URL? = nil) {
        self.id = id
        self.username = username
        self.realname = realname
        self.avatarURL = avatarURL
    }
}

func == (lhs: Me, rhs: Me) -> Bool {
    return lhs.id == rhs.id &&
    lhs.username == rhs.username &&
    lhs.realname == rhs.realname &&
    lhs.avatarURL?.absoluteString == rhs.avatarURL?.absoluteString
}
