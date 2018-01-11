//
//  PostServiceStub.swift
//  SwiftSampleCode
//
//  Created by Adam Borek on 12.06.2016.
//  Copyright © 2016 All in Mobile. All rights reserved.
//

import Foundation
import RxSwift
import RxNimble
import Nimble
import Quick
@testable import SwiftProjectSample

class PostUploaderStub: PostUploader {
    fileprivate (set) var apiProvider: RxAPIProvider<PostEndpoint>
    fileprivate (set) var meService: MeService
    fileprivate (set) var imageResizer: ImageResizer
    
    init() {
        self.apiProvider = StubAPIProvider<PostEndpoint>()
        self.meService = MeService(withUserPersistanceRepository: UserPersistanceRepositoryStub(), geolocationProvider: GeolocationProviderStub())
        self.imageResizer = ImageResizer()
    }
    
    var usedUserInputs: PostUserInputs?
    var givenError: Error?
    
    func upload(_ post: PostUserInputs) -> Observable<Void> {
        usedUserInputs = post
        if let givenError = givenError {
            return Observable.error(givenError)
        } else {
            return Observable.just()
        }
    }
    
    func preparePostToSend(_ userInputs: PostUserInputs) -> PendingPost {
        fatalError("stub does not use this method")
    }
}
