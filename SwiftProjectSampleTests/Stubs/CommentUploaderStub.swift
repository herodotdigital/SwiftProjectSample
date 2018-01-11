//
//  CommentUploaderStub.swift
//  SwiftSampleCode
//
//  Created by Adam Borek on 05.07.2016.
//  Copyright © 2016 All in Mobile. All rights reserved.
//

import Foundation
import RxSwift
import RxNimble
import Nimble
import Quick
@testable import SwiftProjectSample

class CommentUploaderStub: CommentUploaderType {
    var givenComment: Comment!
    
    func upload(_ comment: PendingComment) -> Observable<Comment> {
        return Observable.deferred {
            return Observable.just(self.givenComment)
        }
    }
}
