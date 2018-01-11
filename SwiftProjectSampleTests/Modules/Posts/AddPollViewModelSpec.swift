//
//  AddPollViewModelSpec.swift
//  SwiftSampleCode
//
//  Created by Adam Borek on 19.07.2016.
//  Copyright © 2016 All in Mobile. All rights reserved.
//

import Foundation
import RxSwift
import RxNimble
import Nimble
import Quick
@testable import SwiftProjectSample

class AddPollViewModelSpec: QuickSpec, AddContentViewModelDelegate {
    var sources = [
        fakery.internet.domainName(),
        fakery.commerce.productName()
    ]

    override func spec() {
        describe("AddPollViewModel") {
            var sut: AddPollViewModel!
            var userPersistance: UserPersistanceRepositoryStub!
            var postUploader: PostUploaderStub!

            beforeEach() {
                postUploader = PostUploaderStub()
                userPersistance = UserPersistanceRepositoryStub()
                sut = AddPollViewModel(withPostUploader: postUploader, userPersistenceReader: userPersistance)
                sut.delegate = self
            }

            it("maximum count of answers is 5") {
                expect(sut.maximumAnswers) == 5
            }

            context("when everything is filled properly") {
                var expectedAnswers: [String]!
                beforeEach() {
                    sut.title.value = fakery.lorem.characters(amount: 140)

                    sut.answers[0].value = fakery.lorem.characters(amount: 35)
                    sut.answers[1].value = fakery.lorem.characters(amount: 40)
                    sut.answers[2].value = fakery.lorem.characters(amount: 40)
                    sut.answers[3].value = fakery.lorem.characters(amount: 80)
                    sut.answers[4].value = fakery.lorem.characters(amount: 0)

                    expectedAnswers = [
                        sut.answers[0].value,
                        sut.answers[1].value,
                        sut.answers[2].value,
                        sut.answers[3].value
                    ]

                    sut.sendTaps.onNext()
                }

                it("calculate proper amount of letters") {
                    expect(sut.answersCount[0]) == "35/\(sut.maximumAnswerTextCount)"
                    expect(sut.answersCount[1]) == "40/\(sut.maximumAnswerTextCount)"
                    expect(sut.answersCount[2]) == "40/\(sut.maximumAnswerTextCount)"
                    expect(sut.answersCount[3]) == "80/\(sut.maximumAnswerTextCount)"
                    expect(sut.answersCount[4]) == "0/\(sut.maximumAnswerTextCount)"
                }

                it("is possible to create a post") {
                    expect(sut.possibleToCreatePost) == true
                }

                it("sends poll to the server") {
                    let usedUserInputs = postUploader.usedUserInputs!
                    expect(usedUserInputs.title) == sut.title.value
                    expect(usedUserInputs.sources) == self.sources
                    expect(usedUserInputs.description) == sut.explanation.value
                    expect(usedUserInputs.answers) == expectedAnswers
                    expect(usedUserInputs.image).to(equalOptional(sut.image.value))
                }

                context("when every 5 answers are filled in") {
                    beforeEach() {
                        sut.title.value = fakery.lorem.characters(amount: 140)
                        sut.answers[0].value = fakery.lorem.characters(amount: 35)
                        sut.answers[1].value = fakery.lorem.characters(amount: 40)
                        sut.answers[2].value = fakery.lorem.characters(amount: 40)
                        sut.answers[3].value = fakery.lorem.characters(amount: 80)
                        sut.answers[4].value = fakery.lorem.characters(amount: 79)
                        sut.sendTaps.onNext()
                    }

                    it("passes 5 answers to postUploader") {
                        let usedUserInputs = postUploader.usedUserInputs!
                        expect(usedUserInputs.answers.count) == 5
                    }
                }
            }

            context("when there are filled less than 2 answers") {
                beforeEach() {
                    sut.title.value = fakery.lorem.characters(amount: 140)
                    sut.answers[0].value = fakery.lorem.characters(amount: 35)
                }

                it("is not possible to create a post") {
                    expect(sut.possibleToCreatePost) == false
                }
            }

            context("when answers are changed from correct to empty") {
                beforeEach() {
                    sut.title.value = fakery.lorem.characters(amount: 140)
                    sut.answers[0].value = fakery.lorem.characters(amount: 80)
                    sut.answers[1].value = fakery.lorem.characters(amount: 80)
                    sut.answers[2].value = fakery.lorem.characters(amount: 80)
                    sut.answers[3].value = fakery.lorem.characters(amount: 80)
                    sut.answers[4].value = fakery.lorem.characters(amount: 80)
                }

                it("is possible to create a post before change but is not possible to create it after change") {
                    var result: Bool!
                    _ = sut.possibleToCreatePost.subscribe(onNext: {
                        result = $0
                    }, onError: nil, onCompleted: nil, onDisposed: nil)
                    expect(result) == true
                    sut.answers[1].value = ""
                    sut.answers[2].value = ""
                    sut.answers[3].value = ""
                    sut.answers[4].value = ""
                    expect(result) == false
                }
            }

            context("when one of the answers has more characters than 80") {
                beforeEach() {
                    sut.title.value = fakery.lorem.characters(amount: 140)
                    sut.answers[0].value = fakery.lorem.characters(amount: 81)
                    sut.answers[1].value = fakery.lorem.characters(amount: 80)
                    sut.answers[2].value = fakery.lorem.characters(amount: 80)
                    sut.answers[3].value = fakery.lorem.characters(amount: 80)
                    sut.answers[4].value = fakery.lorem.characters(amount: 80)
                }

                it("is not possible to create a post") {
                    expect(sut.possibleToCreatePost) == false
                }
            }
        }
    }

    func sourcesForThePost() -> [String] {
        return sources
    }
}
