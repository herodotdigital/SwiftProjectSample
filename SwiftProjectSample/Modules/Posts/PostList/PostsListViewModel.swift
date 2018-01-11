//
//  PostsListViewModel.swift
//  SwiftSampleCode
//
//  Created by Adam Borek on 17.06.2016.
//  Copyright © 2016 All in Mobile. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class PostsListViewModel {
    let postsProvider: PostsProvider
    
    init(withPostsProvider postsProvider: PostsProvider) {
        self.postsProvider = postsProvider
    }
    
    func posts() -> Driver<[PostViewModel]> {
        return self.postsProvider.posts.subscribeOn(ConcurrentDispatchQueueScheduler(qos: DispatchQoS.userInitiated))
            .map { posts in
                return posts.flatMap { StatementViewModel(withStatement: $0) }
            }.debug()
            .asDriver(onErrorJustReturn: [])
    }
}
