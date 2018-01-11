//
//  User.swift
//  SwiftSampleCode
//
//  Created by Adam Borek on 13.06.2016.
//  Copyright © 2016 All in Mobile. All rights reserved.
//

import Foundation
import SwiftyJSON

/**
* User Snapshot (in polish: migawka) represents data structure, which contains minimum information about users.
*/
protocol UserSnapshot {
    var id: Int { get }
    var username: String { get }
    var realname: String? { get }
    var avatarURL: URL? { get }
}

func == (lhs: UserSnapshot, rhs: UserSnapshot) -> Bool {
    return lhs.username == rhs.username &&
        lhs.realname == rhs.realname &&
        lhs.id == rhs.id
}

struct MinimalUser: UserSnapshot {
    fileprivate (set) var id: Int
    fileprivate (set) var username: String
    fileprivate (set) var realname: String?
    fileprivate (set) var avatarURL: URL?

    init?(withJSON json: JSON) {
        guard let id = json["id"].int, let username = json["username"].string else { return nil }
        self.id = id
        self.username = username
        self.avatarURL = Assembly.API.parseImageURL(from: json, imagePath: "picture_path", imageName: "picture")
    }

    init(id: Int, username: String, realname: String? = nil, avatarURL: URL? = nil) {
        self.id = id
        self.username = username
        self.realname = realname
        self.avatarURL = avatarURL
    }
    
    /**
     This function is required because of swift type bug. For more information go to [https://forums.developer.apple.com/thread/21540](https://forums.developer.apple.com/thread/21540)
     - returns: Casted MinimalUser to UserSnapshot
     */
    static func parse(_ json: JSON) -> UserSnapshot? {
        return MinimalUser(withJSON: json)
    }
}
