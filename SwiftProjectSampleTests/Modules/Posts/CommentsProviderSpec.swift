//
//  CommentsProviderSpec.swift
//  SwiftSampleCode
//
//  Created by Adam Borek on 01.07.2016.
//  Copyright © 2016 All in Mobile. All rights reserved.
//

import Foundation
import RxSwift
import RxNimble
import Nimble
import Quick
import Moya
@testable import SwiftProjectSample

class CommentsProviderSpec: QuickSpec {
    override func spec() {
        describe("CommentsProvider") {
            var sut: CommentsProvider!
            var apiProvider: StubAPIProvider<CommentsEndpoint>!
            
            beforeEach() {
                apiProvider = StubAPIProvider<CommentsEndpoint>()
                sut = CommentsProvider(withApiProvider: apiProvider)
            }
            
            context("when everything goes ok") {
                var usedTarget: TargetType?
                let statement = FactoryGirl.Post.statement
                var results: [Comment]!
            
                beforeEach() {
                    apiProvider.givenReponse = .json(statusCode: 200, json: FactoryGirl.Comment.jsonList)
                    results = try! sut.comments(for: statement).toBlocking().first()!
                    usedTarget = apiProvider.usedTarget
                }
                
                it("asks for the resources at correct endpoint") {
                    expect(usedTarget?.path) == "posts/\(statement.id)/comments"
                }
                
                sharedExamples("parses the comment") { (context: @escaping SharedExampleContext) in
                    var actual: Comment!
                    var expected: Comment!
                    
                    beforeEach() {
                        let index = context()["atIndex"] as! Int
                        actual = results[index]
                        expected = FactoryGirl.Comment.list[index]
                    }
                    
                    it("parses the id") {
                        expect(actual.id) == expected.id
                    }
                    
                    it("parses the value") {
                        expect(actual.value) == expected.value
                    }
                    
                    it("parses the creation date") {
                        expect(actual.createdAt) == expected.createdAt
                    }
                    
                    it("prses the author") {
                        expect(actual.author.username) == expected.author.username
                        expect(actual.author.realname).to(equalOptional(expected.author.realname))
                        expect(actual.author.avatarURL?.absoluteString).to(equalOptional(expected.author.avatarURL?.absoluteString))
                        expect(actual.author.id) == expected.author.id
                    }
                }
                
                itBehavesLike("parses the comment") { ["atIndex":0] }
                itBehavesLike("parses the comment") { ["atIndex":1] }
                itBehavesLike("parses the comment") { ["atIndex":2] }
            }
        }
    }
}
