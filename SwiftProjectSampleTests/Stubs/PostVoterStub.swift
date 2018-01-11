//
//  PostVoterStub.swift
//  SwiftSampleCode
//
//  Created by Adam Borek on 25.07.2016.
//  Copyright © 2016 All in Mobile. All rights reserved.
//

import Foundation
import RxSwift

@testable import SwiftProjectSample
class PostVoterStub: PostVoter {
    init() {
        super.init(withAPIProvider: StubAPIProvider(), userPersistanceReader: UserPersistanceRepositoryStub())
    }
    
    var shouldFailed = false
    override func vote(onAnswer answer: Answer) -> Observable<Void> {
        if !shouldFailed {
            return Observable.just()
        } else {
            return Observable.error(NSError(domain: "domain", code: 400, userInfo: nil))
        }
    }
}
