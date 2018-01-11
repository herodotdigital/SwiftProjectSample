//
//  PostsProvider.swift
//  SwiftSampleCode
//
//  Created by Adam Borek on 16.06.2016.
//  Copyright © 2016 All in Mobile. All rights reserved.
//

import Foundation
import RxSwift
import RxOptional
import SwiftyJSON
import CoreLocation

enum PostProviderError: Error {
    case locationIsUnkown
}

protocol PostsProvider {
    var posts: Observable<[Post]> { get }
}

class LocalPostsProvider: PostsProvider {
    let meService: MeService
    let postParser: PostParser
    let apiProvider: RxAPIProvider<PostEndpoint>

    init(withAPIProvider provider: RxAPIProvider<PostEndpoint>, meService: MeService, postParser: PostParser ) {
        self.meService = meService
        self.postParser = postParser
        self.apiProvider = provider
    }

    var posts: Observable<[Post]> {
        return userAndHisLocation()
            .flatMap { user, hisLocation in
                return self.apiProvider.requestJSON(.listOfLocals(user: user, userLocation: hisLocation.coordinate))
            }.map(self.postParser.parse)
    }

    fileprivate func userAndHisLocation() -> Observable<(UserSnapshot, CLLocation)> {
        let location = meService.singleMeLocationUpdate.errorOnNil(PostProviderError.locationIsUnkown)
        let me = meService.rx_currentUser
        return Observable.zip(me, location) { ($0, $1) }
    }
}


class HotPostsProvider: PostsProvider {
    let apiProvider: RxAPIProvider<PostEndpoint>
    let userPersistanceReader: UserPersistenceReader
    let postParser: PostParser

    init(withAPIProvider provider: RxAPIProvider<PostEndpoint>, userPersistanceReader: UserPersistenceReader, postParser: PostParser ) {
        self.apiProvider = provider
        self.userPersistanceReader = userPersistanceReader
        self.postParser = postParser
    }

    var posts: Observable<[Post]> {
        return userPersistanceReader.rx_currentUser
            .flatMap { user in
                return self.apiProvider.requestJSON(.listOfHots(user: user))
            }.map(self.postParser.parse)
    }
}

class FollowingPostsProvider: PostsProvider {
    let apiProvider: RxAPIProvider<PostEndpoint>
    let userPersistanceReader: UserPersistenceReader
    let postParser: PostParser

    init(withAPIProvider provider: RxAPIProvider<PostEndpoint>, userPersistanceReader: UserPersistenceReader, postParser: PostParser ) {
        self.apiProvider = provider
        self.userPersistanceReader = userPersistanceReader
        self.postParser = postParser
    }

    var posts: Observable<[Post]> {
        return userPersistanceReader.rx_currentUser
            .flatMap { user in
                return self.apiProvider.requestJSON(.listOfFollowingPosts(user: user))
            }.map(self.postParser.parse)
    }
}
