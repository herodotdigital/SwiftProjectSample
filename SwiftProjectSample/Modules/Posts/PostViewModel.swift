//
//  PostViewModel.swift
//  SwiftSampleCode
//
//  Created by Adam Borek on 26.07.2016.
//  Copyright © 2016 All in Mobile. All rights reserved.
//

import Foundation

protocol PostViewModel {
    var post: Post { get }
}

extension PostViewModel {
    var title: String {
        return post.title
    }
    
    var ownername: String {
        return post.owner.username
    }
    
    var ownerAvatar: URL? {
        return post.owner.avatarURL as URL?
    }
    
    var postTime: String {
        return (post.creationDate as NSDate).timeAgoSinceNow().uppercased()
    }
    
    var image: URL? {
        return post.imageURL as URL?
    }
    
    var explanation: String? {
        return post.description
    }
    
    var sources: [String] {
        return post.sources
    }
}
