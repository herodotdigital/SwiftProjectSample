//
//  CommentUploader.swift
//  SwiftSampleCode
//
//  Created by Adam Borek on 04.07.2016.
//  Copyright © 2016 All in Mobile. All rights reserved.
//

import Foundation
import RxSwift
import RxNimble
import Nimble
import Quick
@testable import SwiftProjectSample

class CommentUploaderSpec: QuickSpec {
    override func spec() {
        describe("CommentUploader") {
            var sut: CommentUploader!
            var apiProvider: StubAPIProvider<CommentsEndpoint>!
            var userReader: UserPersistanceRepositoryStub!
            
            beforeEach() {
                apiProvider = StubAPIProvider<CommentsEndpoint>()
                userReader = UserPersistanceRepositoryStub()
                sut = CommentUploader(withApiProvider: apiProvider, userReader:  userReader)
            }
            
            context("when everything goes right") {
                let statement = FactoryGirl.Post.statement
                let pendingComment = PendingComment(comment: fakery.lorem.sentences(), post: statement)
                let me = FactoryGirl.Me.object
                var usedParams: [String:AnyObject]?
                beforeEach() {
                    apiProvider.givenReponse = .json(statusCode:200, json:FactoryGirl.Comment.jsonList[0])
                    userReader.givenCurrentUser = me
                    _ = try! sut.upload(pendingComment).toBlocking().first()!
                    usedParams = apiProvider.usedTarget?.parameters?["post_comment"] as? [String: AnyObject]
                }
                
                it("sends request to corrent URL") {
                    expect(apiProvider.usedTarget?.path) == "posts/comments"
                }
                
                it("sends post id") {
                    expect(usedParams?["post"] as? Int) == statement.id
                }
                
                it("sends value of comment") {
                    expect(usedParams?["value"] as? String) == pendingComment.value
                }
                
                it("sends user id") {
                    expect(usedParams?["user"] as? Int) == me.id
                }
            }
        }
    }
}
