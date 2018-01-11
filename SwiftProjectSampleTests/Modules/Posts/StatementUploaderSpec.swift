//
//  PostServiceSpec.swift
//  SwiftSampleCode
//
//  Created by Adam Borek on 08.06.2016.
//  Copyright © 2016 All in Mobile. All rights reserved.
//

import Foundation

import RxSwift
import RxNimble
import Nimble
import Quick
import CoreLocation
import SwiftyJSON
@testable import SwiftProjectSample

extension String {
    func imageFromBase64() -> UIImage? {
        return Data(base64Encoded: self, options: [.ignoreUnknownCharacters]).flatMap {
            UIImage(data: $0)
        }
    }
}

class StatementUploaderSpec: QuickSpec {
    override func spec() {
        describe("StatementUploader") {
            var sut: StatementUploader!
            var apiProvider: StubAPIProvider<PostEndpoint>!
            var userPersistanceRepositroy: UserPersistanceRepositoryStub!
            var meService: MeServiceStub!
            let currentUser = FactoryGirl.Me.object
            
            beforeEach() {
                apiProvider = StubAPIProvider()
                userPersistanceRepositroy = UserPersistanceRepositoryStub()
                userPersistanceRepositroy.givenCurrentUser = currentUser
                meService = MeServiceStub(withUserPersistanceRepositoryStub: userPersistanceRepositroy)
                sut = StatementUploader(withAPIProvider: apiProvider, meService: meService)
            }
            
            describe("#upload") {
                let userInputs = FactoryGirl.Post.statementUserInputs
                context("ends with success") {
                    let location = FactoryGirl.Geolocation.location
                    var usedRequestParams: JSON!
                    beforeEach() {
                        meService.givenLocation = location
                        _ = try! sut.upload(userInputs).toBlocking().first()!
                        let params = apiProvider.usedTarget!.parameters as Any
                        usedRequestParams = JSON(params)
                    }
                
                    it("sends who is the autor") {
                        expect(usedRequestParams["post"]["autor"].int) == currentUser.id
                    }
                    
                    it("sends a type as statement") {
                        expect(usedRequestParams["post"]["type"].string) == "statement"
                    }
                    
                    it("sends the title") {
                        expect(usedRequestParams["post"]["title"].string) == userInputs.title
                    }
                    
                    it("sends the description") {
                        expect(usedRequestParams["post"]["description"].string) == userInputs.description
                    }
                    
                    it("sends the locations of current user") {
                        expect(usedRequestParams["post"]["lat"].string) == String(location.coordinate.latitude)
                        expect(usedRequestParams["post"]["lng"].string) == String(location.coordinate.longitude)
                    }
                    
                    it("sends URLs attached to the post") {
                        for (index, source) in userInputs.sources.enumerated() {
                            let usedUrls = usedRequestParams["post"]["urls"]
                            expect(usedUrls["\(index)"].string) == source
                        }
                    }
                    
                    it("sends agree and disagree as possible answers") {
                        let questionArray = usedRequestParams["post"]["questions"].array
                        expect(questionArray?[0]["value"].string) == "disagree"
                        expect(questionArray?[1]["value"].string) == "agree"
                    }
                    
                    it("sends image which is not bigger than 1080x1080 px") {
                        let usedImage = usedRequestParams["post"]["imageFile"].string?.imageFromBase64()
                        expect(usedImage?.size.width).to(beLessThanOrEqualTo(1080))
                        expect(usedImage?.size.height).to(beLessThanOrEqualTo(1080))
                    }
                    
                    it("keeps ratio of the original image") {
                        let sentImage = usedRequestParams["post"]["imageFile"].string?.imageFromBase64()
                        let originalImage = userInputs.image
                        let originalRatio = originalImage!.size.width / originalImage!.size.height
                        let sentImageRatio = sentImage!.size.width / sentImage!.size.height
                        
                        expect(sentImageRatio).to(beCloseTo(originalRatio, within: 0.001))
                    }
                }
                
                
                context("when user deny the location") {
                    beforeEach() {
                        meService.givenLocation = nil
                        _ = try! sut.upload(userInputs).toBlocking().first()!
                    }
                    
                    it("sends params") {
                        expect(apiProvider.usedTarget?.parameters).toNot(beNil())
                    }
                    
                    it("doesnt send a location") {
                        expect(apiProvider.usedTarget?.parameters?["post[lat]"]).to(beNil())
                        expect(apiProvider.usedTarget?.parameters?["post[long]"]).to(beNil())
                    }
                }
                
                context("when server return error") {
                    var errorResult: Error!
                    
                    beforeEach() {
                        apiProvider.givenReponse = .json(statusCode: 400, json: JSON(dictionaryLiteral:("error", "dummyError")))
                        do {
                            _ = try sut.upload(userInputs).toBlocking().first()
                        } catch let error {
                            errorResult = error
                        }
                    }
                    
                    it("reports an error") {
                        expect(errorResult).toNot(beNil())
                    }
                }
            }
        }
    }
}

