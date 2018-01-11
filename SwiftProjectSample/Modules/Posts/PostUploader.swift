//
//  PostService.swift
//  SwiftSampleCode
//
//  Created by Adam Borek on 08.06.2016.
//  Copyright © 2016 All in Mobile. All rights reserved.
//

import Foundation
import RxSwift
import RxOptional
import RxCocoa
import CoreLocation

protocol PostUploader {
    var apiProvider: RxAPIProvider<PostEndpoint> {get}
    var meService: MeService {get}
    var imageResizer: ImageResizer {get}
 
    /**
     Method which allow to upload a post to the server. Before sending the post to the server it asks database for current user to determine who is the author of the post.
     It also ask for the current location of the user.
     - parameter post: PendingPost struct which describes the post
     - returns: Observable with Void which indicates if uploading ends with success send onNext with void parameter. Otherwise it thorws an error.
     */
    func upload(_ userInputs: PostUserInputs) -> Observable<Void>
    func preparePostToSend(_ userInputs: PostUserInputs) -> PendingPost
}

extension PostUploader {
    func upload(_ post: PostUserInputs) -> Observable<Void> {
        let userAndHisLocation = getUserAndHisLocation()
        let preparedPost = preparePostToSend(post)
        let postWithResizedImage = pendingPostWithResizedImage(preparedPost)
        return Observable.combineLatest(userAndHisLocation, postWithResizedImage) { ($0.0, $0.1, $1) }
            .timeout(15, scheduler: ConcurrentDispatchQueueScheduler(qos: .default))
            .flatMap { (user, currentLocation, postWithResizedImage) in
                return self.apiProvider.requestJSON(.createNewPost(post: postWithResizedImage, author: user, userLocation: currentLocation?.coordinate))
            }.mapToVoid()
    }
    
    fileprivate func getUserAndHisLocation() -> Observable<(Me, CLLocation?)> {
        let currentUser = meService.rx_currentUser
        let curentUsersLocation = meService.singleMeLocationUpdate
            .timeout(5, scheduler: ConcurrentDispatchQueueScheduler(qos: .default))
            .catchErrorJustReturn(nil)
        
        return Observable.zip(currentUser, curentUsersLocation) { ($0, $1) }
    }
    
    fileprivate func pendingPostWithResizedImage(_ post: PendingPost) -> Observable<PendingPost> {
        guard let imageToResize = post.userInputs.image else { return Observable.just(post) }
        return imageResizer.rx_resize(imageToResize, toFitSize: CGSize(width: 1080, height: 1080))
            .map { resizedImage in
                var postWithResizedImage = post
                postWithResizedImage.userInputs.image = resizedImage
                return postWithResizedImage
        }
    }
}

class StatementUploader: PostUploader {
    let apiProvider: RxAPIProvider<PostEndpoint>
    let meService: MeService
    let imageResizer = ImageResizer()
    
    init(withAPIProvider apiProvider: RxAPIProvider<PostEndpoint>, meService: MeService) {
        self.apiProvider = apiProvider
        self.meService = meService
    }
    
    func preparePostToSend(_ userInputs: PostUserInputs) -> PendingPost {
        return PendingStatement(userInputs: userInputs)
    }
}

class PollUploader: PostUploader {
    let apiProvider: RxAPIProvider<PostEndpoint>
    let meService: MeService
    let imageResizer = ImageResizer()
    
    init(withAPIProvider apiProvider: RxAPIProvider<PostEndpoint>, meService: MeService) {
        self.apiProvider = apiProvider
        self.meService = meService
    }
    
    func preparePostToSend(_ userInputs: PostUserInputs) -> PendingPost {
        return PendingPoll(userInputs: userInputs)
    }
}
