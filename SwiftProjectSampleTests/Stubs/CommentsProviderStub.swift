//
//  CommentsProviderStub.swift
//  SwiftSampleCode
//
//  Created by Adam Borek on 04.07.2016.
//  Copyright © 2016 All in Mobile. All rights reserved.
//

import Foundation
@testable import SwiftProjectSample
import RxSwift

class CommentsProviderStub: CommentsProvider {
    var givenComments: [Comment] = FactoryGirl.Comment.list
    
    init() {
        super.init(withApiProvider: StubAPIProvider())
    }
    
    override func comments(for statement: Post) -> Observable<[Comment]> {
        return Observable.deferred {
            return Observable.just(self.givenComments)
        }
    }
}
