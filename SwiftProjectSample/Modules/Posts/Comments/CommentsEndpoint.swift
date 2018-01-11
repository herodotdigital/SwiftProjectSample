//
//  CommentsEndpoint.swift
//  SwiftSampleCode
//
//  Created by Adam Borek on 01.07.2016.
//  Copyright © 2016 All in Mobile. All rights reserved.
//

import Foundation
import Moya

enum CommentsEndpoint {
    case listOfComments(statement: Post)
    case createComment(comment: PendingComment, user:UserSnapshot)
}

extension CommentsEndpoint: EncodableTargetType {
    var path: String {
        switch self {
        case .listOfComments(let statement):
            return "posts/\(statement.id)/comments"
        case .createComment:
            return "posts/comments"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .listOfComments:
            return .get
        case .createComment:
            return .post
        }
    }
    
    var parameters: [String : Any]? {
        switch self {
        case .createComment(let comment, let user):
            return [
                "post_comment": [
                    "post":comment.postId,
                    "value":comment.value,
                    "user":user.id
                ]
            ]
        default:
            return nil
        }
    }
    
    var sampleData: Data {
        switch self {
        case .createComment:
            return sampleDebugData(fromFileNamed: "POST_post-comments", ofType: ".json") as Data
        case .listOfComments:
            return sampleDebugData(fromFileNamed: "GET_post-comments_success", ofType: ".json") as Data
        }
    }
}
