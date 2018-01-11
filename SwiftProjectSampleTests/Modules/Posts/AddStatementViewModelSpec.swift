//
//  AddPostViewModelSpec.swift
//  SwiftSampleCode
//
//  Created by Adam Borek on 12.06.2016.
//  Copyright © 2016 All in Mobile. All rights reserved.
//

import Foundation
import RxSwift
import RxNimble
import Nimble
import RxCocoa
import Quick
@testable import SwiftProjectSample

class AddStatementViewModelSpec: QuickSpec, AddContentViewModelDelegate {
    var sources = [
        fakery.internet.domainName(),
        fakery.commerce.productName()
    ]
    
    override func spec() {
        describe("AddPostViewModel") {
            var sut: AddStatementViewModel!
            var postUploader: PostUploaderStub!
            var userReader: UserPersistanceRepositoryStub!
            let titleMaxCount = 140
            let me = FactoryGirl.Me.object
            
            beforeEach() {
                postUploader = PostUploaderStub()
                userReader = UserPersistanceRepositoryStub()
                userReader.givenCurrentUser = me
                sut = AddStatementViewModel(withPostUploader: postUploader, userPersistenceReader: userReader)
                sut.maximumTitleCount = titleMaxCount
            }
            context("when everything is filled correnctly") {
                let title = fakery.lorem.characters(amount: titleMaxCount)
                let explanation = fakery.lorem.paragraph(sentencesAmount: 1)
                
                beforeEach() {
                    sut.title.value = title
                    sut.explanation.value = explanation
                    sut.delegate = self
                    sut.sendTaps.onNext()
                }
        
                it("creates actual title count text") {
                    expect(sut.titleCount) == "140/140"
                }
                
                it("marks it is possible to create a post") {
                    expect(sut.possibleToCreatePost) == true
                }
                
                it("get postOwnername from current user") {
                    expect(sut.postOwnername) == me.username
                }
                
                it("sends post with filled informations") {
                    let usedUserInputs = postUploader.usedUserInputs!
                    expect(usedUserInputs.title) == title
                    expect(usedUserInputs.sources) == self.sources
                    expect(usedUserInputs.description) == explanation
                }
            }
            
            pending("when post service return error") {
                beforeEach() {
                    //postUploader.givenError = FactoryGirl.API.unknownError
                    sut.title.value = fakery.lorem.characters(amount: titleMaxCount)
                    sut.explanation.value = fakery.lorem.paragraph(sentencesAmount: 1)
                    sut.delegate = self
                    sut.sendTaps.onNext()
                }
                
                it("is possible to tap and send request ones again") {
                    expect(postUploader.usedUserInputs).notTo(beNil())
                    postUploader.usedUserInputs = nil
                    sut.sendTaps.onNext()
                    expect(postUploader.usedUserInputs).notTo(beNil())
                }
            }
            
            context("when title is bigger than maximum count") {
                let title = fakery.lorem.characters(amount: 141)
                beforeEach() {
                    sut.title.value = title
                }
                
                it("marks possibility to send post as disable") {
                    expect(sut.possibleToCreatePost) == false
                }
                
                it("create actual title count text") {
                    expect(sut.titleCount) == "141/140"
                }
            }
        }
    }
    
    func sourcesForThePost() -> [String] {
        return sources
    }
}
