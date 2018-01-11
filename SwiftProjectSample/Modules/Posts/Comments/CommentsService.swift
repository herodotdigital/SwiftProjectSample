//
//  CommentService.swift
//  SwiftSampleCode
//
//  Created by Adam Borek on 05.07.2016.
//  Copyright © 2016 All in Mobile. All rights reserved.
//

import Foundation
import RxSwift

class CommentsService {
    fileprivate let commentsProvider: CommentsProviderType
    fileprivate let commentUploader: CommentUploaderType
    
    init(withCommentsProvider commentsProvider: CommentsProviderType, commentUploader: CommentUploaderType) {
        self.commentsProvider = commentsProvider
        self.commentUploader = commentUploader
    }
}

extension CommentsService: CommentsProviderType {
    func comments(for statement: Post) -> Observable<[Comment]> {
        return commentsProvider.comments(for: statement)
    }
}

extension CommentsService: CommentUploaderType {
    func upload(_ comment: PendingComment) -> Observable<Comment> {
        return commentUploader.upload(comment)
    }
}
