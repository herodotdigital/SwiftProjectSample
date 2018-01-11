//
//  CommentUploader.swift
//  SwiftSampleCode
//
//  Created by Adam Borek on 04.07.2016.
//  Copyright © 2016 All in Mobile. All rights reserved.
//

import Foundation
import RxSwift
import SwiftyJSON

struct PendingComment {
    let postId: Int
    let value: String
    
    init(comment: String, post: Post) {
        value = comment
        postId = post.id
    }
}

protocol CommentUploaderType {
    func upload(_ comment: PendingComment) -> Observable<Comment>
}

class CommentUploader: CommentUploaderType {
    fileprivate let apiProvider: RxAPIProvider<CommentsEndpoint>
    fileprivate let userReader: UserPersistenceReader
    
    init(withApiProvider apiProvider: RxAPIProvider<CommentsEndpoint>, userReader: UserPersistenceReader) {
        self.apiProvider = apiProvider
        self.userReader = userReader
    }
    
    func upload(_ comment: PendingComment) -> Observable<Comment> {
        return self.userReader.rx_currentUser
            .flatMap { self.sendToApi(comment, createdBy: $0) }
            .map(tryToParseComment)
    }
    
    fileprivate func sendToApi(_ comment: PendingComment, createdBy user: UserSnapshot) -> Observable<JSON> {
        return apiProvider.requestJSON(.createComment(comment:comment, user:user))
    }
    
    fileprivate func tryToParseComment(from json: JSON) throws -> Comment {
        guard let comment = Comment(withJSON: json) else {
            throw APIError(json: json, message: "Cannot parse comment from JSON")
        }
        return comment
    }
}
