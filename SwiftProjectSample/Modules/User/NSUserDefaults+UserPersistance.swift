//
//  NSUserDefaults+UserPersistance.swift
//  SwiftSampleCode
//
//  Created by Adam Borek on 07.06.2016.
//  Copyright © 2016 All in Mobile. All rights reserved.
//

import Foundation
import RxSwift

private let userIdKey = "user_id"
private let userUsernameKey = "user_username"
private let userRealnameKey = "user_realname"
private let userAvatarKey = "user_avatar"

extension UserDefaults : UserPersistenceRepository {
    func save(_ user: Me) -> Bool {
        setValue(user.id, forKey: userIdKey)
        setValue(user.username, forKey: userUsernameKey)
        setValue(user.realname, forKey: userRealnameKey)
        setValue(user.avatarURL?.absoluteString, forKey: userAvatarKey)
        synchronize()
        return true
    }

    var currentUser: Me? {
        guard let username = string(forKey: userUsernameKey) else { return nil }
        let realname = string(forKey: userRealnameKey)
        let id = integer(forKey: userIdKey)
        let avatar = string(forKey: userAvatarKey)
            .flatMap(URLComponents.init)
            .flatMap {$0.url}
        let user = Me(id: id, username: username, realname: realname, avatarURL: avatar)
        return user
    }
}
