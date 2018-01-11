//
//  PostVoterSpec.swift
//  SwiftSampleCode
//
//  Created by Adam Borek on 27.06.2016.
//  Copyright © 2016 All in Mobile. All rights reserved.
//

import Foundation
import Moya
import RxSwift
import RxNimble
import Nimble
import SwiftyJSON
import Quick
@testable import SwiftProjectSample

class PostVoterSpec: QuickSpec {
    override func spec() {
        describe("PostVoter") {
            var sut: PostVoter!
            var apiProvider: StubAPIProvider<PostEndpoint>!
            var userPersistanceReader: UserPersistanceRepositoryStub!
            
            beforeEach() {
                apiProvider = StubAPIProvider()
                userPersistanceReader = UserPersistanceRepositoryStub()
                sut = PostVoter(withAPIProvider: apiProvider, userPersistanceReader: userPersistanceReader)
            }
            
            context("when everything goes ok") {
                let me = FactoryGirl.Me.object
                let answerToVote = FactoryGirl.Post.statement.answers.first!
                var voteJSONRoot: JSON!
                var usedTarget: TargetType?
                
                beforeEach() {
                    userPersistanceReader.givenCurrentUser = me
                    _ = try! sut.vote(onAnswer: answerToVote).toBlocking().first()!
                    usedTarget = apiProvider.usedTarget
                    voteJSONRoot = JSON(usedTarget!.parameters!["post_question_vote"]!)
                }
                
                it("sends request to correct endpoint") {
                    expect(usedTarget?.path) == "posts/questions/votes"
                }
                
                it("sends me id to the API") {
                    expect(voteJSONRoot["user"].int) == me.id
                }
                
                it("sends answer id") {
                    expect(voteJSONRoot["postQuestion"].int) == answerToVote.id
                }
            }
        }
    }
}
