//
//  PollUploaderSpec.swift
//  SwiftSampleCode
//
//  Created by Adam Borek on 20.07.2016.
//  Copyright © 2016 All in Mobile. All rights reserved.
//

import Foundation
import RxSwift
import RxNimble
import Nimble
import Quick
import SwiftyJSON
import Moya

@testable import SwiftProjectSample

class PollUploaderSpec: QuickSpec {
    override func spec() {
        describe("PollUploader") {
            var sut: PollUploader!
            var apiProvider: StubAPIProvider<PostEndpoint>!
            var meService: MeServiceStub!
            var userRepository: UserPersistanceRepositoryStub!
            
            beforeEach() {
                apiProvider = StubAPIProvider()
                userRepository = UserPersistanceRepositoryStub()
                meService = MeServiceStub(withUserPersistanceRepositoryStub: userRepository)
                sut = PollUploader(withAPIProvider: apiProvider, meService: meService)
            }
            
            describe("#upload") {
                context("when everything goes fine") {
                    var userInputs: PostUserInputs!
                    var usedRequest: TargetType!
                    beforeEach() {
                        apiProvider.givenReponse = .json(statusCode: 200, json: JSON(dictionaryLiteral: ("status","success")))
                        userRepository.givenCurrentUser = FactoryGirl.Me.object
                        meService.givenLocation = FactoryGirl.Geolocation.location
                        userInputs = FactoryGirl.Post.pollUserInputs
                        _ = try! sut.upload(userInputs).toBlocking().first()
                        usedRequest = apiProvider.usedTarget
                    }
                    
                    it("sends answers for the poll") {
                        let usedParams = JSON(usedRequest.parameters!["post"]!)
                        let questionsJSON = usedParams["questions"].array!
                        
                        expect(questionsJSON.count) == userInputs.answers.count
                        zip(questionsJSON, userInputs.answers).forEach { questionJSON, answer in
                            expect(questionJSON["value"].string) == answer
                        }
                    }
                    
                    it("sends poll type of the post") {
                        expect(((usedRequest.parameters?["post"] as! [String:Any])["type"])as? String) == "poll"
                    }
                }
            }
        }
    }
}
