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
import Moya
import Quick
import SwiftyJSON
@testable import SwiftProjectSample
import Foundation

class LocalPostsProviderSpec: QuickSpec {
    override func spec() {
        describe("LocalPostsProvider") {
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
                let meService =  MeService(withUserPersistanceRepository: userRepository, geolocationProvider: geolocationProvider)
                sut = LocalPostsProvider(withAPIProvider: apiProvider, meService:meService, postParser: postParser)
            }
            
            context("when everything goes ok") {
                var usedTarget: TargetType?
                let location = FactoryGirl.Geolocation.location
                let me = FactoryGirl.Me.object
                var result: [Post]!
                beforeEach() {
                    geolocationProvider.givenLocationSequence = [location]
                    userRepository.givenCurrentUser = me
                    apiProvider.givenReponse = .json(statusCode:200, json: JSON([:]))
                    postParser.givenStatements = FactoryGirl.Post.list
                    result = try! sut.posts.toBlocking().first()
                    usedTarget = apiProvider.usedTarget
                }
                
                it("sends GET request to post endpoint") {
                    expect(usedTarget?.path) == "posts"
                    expect(usedTarget?.method) == .get
                }
                
                it("sends type parameter as local") {
                    expect(usedTarget?.parameters?["type"] as? String) == "local"
                }
                
                it("sends user location") {
                    expect(usedTarget?.parameters?["lat"] as? String) == String(location.coordinate.latitude)
                    expect(usedTarget?.parameters?["lng"] as? String) == String(location.coordinate.longitude)
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
