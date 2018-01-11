//
//  UserPersistance.swift
//  SwiftSampleCode
//
//  Created by Adam Borek on 07.06.2016.
//  Copyright © 2016 All in Mobile. All rights reserved.
//

import Foundation
import RxSwift

struct UserIsNotLoggedInError: Error {}

protocol UserPersistenceRepository: UserPersistenceReader, UserPersistenceWriter {
}

protocol UserPersistenceReader {
    var currentUser: Me? { get }
}

protocol UserPersistenceWriter {
    func save(_ user: Me) -> Bool
}

extension UserPersistenceReader {
    /**
     Returns `Me` structure wrapped with `Observable`. It may error with `UserIsNotLoggedInError`
     */
    var rx_currentUser: Observable<Me> {
        return Observable.deferred {
            Observable.just(self.currentUser)
            }.errorOnNil(UserIsNotLoggedInError())
    }
}

class SampleUserPersistenceRepository: UserPersistenceRepository {
    var currentUser: Me? {
        let me = Me(id: 5, username: "theuser", realname: "Donald Hodor", avatarURL: URL(string: "http://www.jqueryscript.net/images/Simplest-Responsive-jQuery-Image-Lightbox-Plugin-simple-lightbox.jpg")!)
        return me
    }
    
    func save(_ user: Me) -> Bool {
        return true
    }
}
