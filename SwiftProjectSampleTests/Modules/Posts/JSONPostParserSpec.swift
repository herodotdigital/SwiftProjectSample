//
//  JSONPostParserSpec.swift
//  SwiftSampleCode
//
//  Created by Adam Borek on 29.06.2016.
//  Copyright © 2016 All in Mobile. All rights reserved.
//

import Foundation
import RxSwift
import RxNimble
import Nimble
import Quick
@testable import SwiftProjectSample

public func equalOptional<T: Equatable>(_ expectedValue: T?) -> MatcherFunc<T> {
    return MatcherFunc() { actualExpression, failureMessage -> Bool in
        failureMessage.postfixMessage = "equal <\(expectedValue)>"
        let actualValue = try actualExpression.evaluate()
        failureMessage.actualValue = "\(actualValue)"
        
        let matches = actualValue == expectedValue
        return matches
    }
}

class JSONPostParserSpec: QuickSpec {
    override func spec() {
        describe("JSONPostParser") {
            let response = FactoryGirl.Post.jsonList
            
            let sut = JSONPostParser()
            var result: [Post]!
            
            beforeEach() {
                result = try! sut.parse(collectionResponse: response)
            }
    
            sharedExamples("parses post") { (context: @escaping SharedExampleContext) in
                var actual: Post!
                var expected: Post!
                
                beforeEach() {
                    let index = context()["atIndex"] as! Int
                    actual = result[index]
                    expected = FactoryGirl.Post.list[index]
                }
                
                it("parses the id") {
                    expect(actual.id) == expected.id
                }
                
                it("parses the title") {
                    expect(actual.title) == expected.title
                }
                
                it("parses the description") {
                    expect(actual.description).to(equalOptional(expected.description))
                }
                
                it("parses the owner") {
                    expect(actual.owner.id) == expected.owner.id
                    expect(actual.owner.username) == expected.owner.username
                    expect(actual.owner.avatarURL?.absoluteString).to(equalOptional(expected.owner.avatarURL?.absoluteString))
                }
                
                it("parses the image URL") {
                    expect(actual.imageURL?.absoluteString).to(equalOptional(expected.imageURL?.absoluteString))
                }
                
                it("parses the creation date") {
                    expect(actual.creationDate) == expected.creationDate
                }
                
                it("parses the sources") {
                    expect(actual.sources.count) == expected.sources.count
                    for (index, source) in expected.sources.enumerated() {
                        expect(actual.sources[index]) == source
                    }
                }
                
                it("parses the answers") {
                    expect(actual.answers.count) == expected.answers.count
                    zip(actual.answers, expected.answers).forEach { actual, expected in
                        expect(actual) == expected
                    }
                }
                
                it("parses current state") {
                    expect(actual.state) == expected.state
                }
            }
            
            it("should parse only valid posts") {
                expect(result.count) == 3
            }
            
            itBehavesLike("parses post") { ["atIndex": 0] }
            itBehavesLike("parses post") { ["atIndex": 1] }
            itBehavesLike("parses post") { ["atIndex": 2] }
        }
    }
}
