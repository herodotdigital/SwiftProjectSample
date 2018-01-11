//
//  File.swift
//  SwiftSampleCode
//
//  Created by Adam Borek on 07.06.2016.
//  Copyright © 2016 All in Mobile. All rights reserved.
//

import Foundation
@testable import SwiftProjectSample
import RxSwift

class UserPersistanceRepositoryStub: UserPersistenceRepository {
    
    var givenCurrentUser: Me? = FactoryGirl.Me.object
    var usedUserToSave: Me?
    
    func save(_ user: Me) -> Bool {
        usedUserToSave = user
        return usedUserToSave != nil
    }
    
    var currentUser: Me? {
        return givenCurrentUser
    }
    
    var rx_currentUser: Observable<Me> {
        return Observable.just(givenCurrentUser)
            .errorOnNil(UserIsNotLoggedInError())
    }
}
