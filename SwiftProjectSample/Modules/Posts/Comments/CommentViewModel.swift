//
//  CommentViewModel.swift
//  SwiftSampleCode
//
//  Created by Adam Borek on 05.07.2016.
//  Copyright © 2016 All in Mobile. All rights reserved.
//

import Foundation
class CommentViewModel: Hashable {
    let comment: Comment
    
    var value: String {
        return comment.value
    }
    
    var authorAvatar: URL? {
        return comment.author.avatarURL as! URL
    }
    
    var authorUsername: String {
        return comment.author.username
    }
    
    let timePast: String
    
    init(withComment comment: Comment) {
        self.comment = comment
        timePast = (comment.createdAt as NSDate).timeAgoSinceNow()
    }
    
    var hashValue: Int {
        return comment.hashValue
    }
}

func == (lhs: CommentViewModel, rhs: CommentViewModel) -> Bool {
    return lhs.comment == rhs.comment
}
