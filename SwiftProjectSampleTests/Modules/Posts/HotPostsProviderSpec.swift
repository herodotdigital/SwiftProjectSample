//
//  PostsProviderSpec.swift
//  SwiftSampleCode
//
//  Created by Adam Borek on 16.06.2016.
//  Copyright © 2016 All in Mobile. All rights reserved.
//
import RxSwift
import RxNimble
import Nimble
import Quick
import SwiftyJSON
import Moya
@testable import SwiftProjectSample
import Foundation

class HotPostsProviderSpec: QuickSpec {
    override func spec() {
        describe("HotPostsProvider") {
            var sut: PostsProvider!
            var apiProvider: StubAPIProvider<PostEndpoint>!
            var geolocationProvider: GeolocationProviderStub!
            var userRepository: UserPersistanceRepositoryStub!
            var postParser: StubPostsParser!
            
            beforeEach() {
                apiProvider = StubAPIProvider<PostEndpoint>()
                geolocationProvider = GeolocationProviderStub()
                userRepository = UserPersistanceRepositoryStub()
                postParser = StubPostsParser()
                sut = HotPostsProvider(withAPIProvider: apiProvider, userPersistanceReader: userRepository, postParser: postParser)
            }
            
            context("when everything goes ok") {
                var usedTarget: TargetType!
                let location = FactoryGirl.Geolocation.location
                let me = FactoryGirl.Me.object
                var result: [Post]!
                beforeEach() {
                    geolocationProvider.givenLocationSequence = [location]
                    userRepository.givenCurrentUser = me
                    postParser.givenStatements = FactoryGirl.Post.list
                    apiProvider.givenReponse = .json(statusCode: 200, json:JSON([:]))
                    result = try! sut.posts.toBlocking().first()
                    usedTarget = apiProvider.usedTarget
                }
                
                it("sends GET request to post endpoint") {
                    expect(usedTarget?.path) == "posts"
                    expect(usedTarget?.method) == .get
                }
                
                it("sends type parameter as hot") {
                    expect(usedTarget?.parameters?["type"] as? String) == "hot"
                }
                
                it("sends select paramter to mark what fields we need") {
                    expect(usedTarget?.parameters?["select"] as? String) == "p.id, p.type, p.title, p.description, p.image, p.createdAt, p.urls, a.id as user_id, a.username, a.picture as autor_picture"
                }
                
                it("sends user id") {
                    expect(usedTarget?.parameters?["user"] as? Int) == me.id
                }
                
                it("parses the response") {
                    expect(result).to(haveCount(postParser.givenStatements!.count))
                }
            }
        }
    }
}
