//
//  UserPersistanceSpec.swift
//  SwiftSampleCode
//
//  Created by Adam Borek on 07.06.2016.
//  Copyright © 2016 All in Mobile. All rights reserved.
//

import Foundation
import Quick
import RxNimble
import Nimble
@testable import SwiftProjectSample

private let userIdKey = "user_id"
private let userUsernameKey = "user_username"
private let userRealnameKey = "user_realname"
private let userAvatarKey = "user_avatar"

class UserPersistanceSpec: QuickSpec {
    override func spec() {
        let sut = UserDefaults.standard

        let clearUserDefaults: (() -> Void) = {
            sut.setValue(nil, forKey: userIdKey)
            sut.setValue(nil, forKey: userUsernameKey)
            sut.setValue(nil, forKey: userRealnameKey)
            sut.setValue(nil, forKey: userAvatarKey)
        }

        let mockCurrentUser: (() -> Void) = {
            sut.setValue(2, forKey: userIdKey)
            sut.setValue("username", forKey: userUsernameKey)
            sut.setValue("realname", forKey: userRealnameKey)
            sut.setValue("http://www.allinmobile.co/image.jpg", forKey: userAvatarKey)
        }

        beforeEach() {
            clearUserDefaults()
        }
        
        afterSuite() {
            clearUserDefaults()
        }

        describe("#getCurrentUser") {
            context("when user is saved") {
                let expectedUser = Me(id: 2, username: "username", realname: "realname", avatarURL: URL(string: "http://www.allinmobile.co/image.jpg"))
                beforeEach() {
                    mockCurrentUser()
                }

                it("reads user") {
                    expect(sut.currentUser) == expectedUser
                }
            }

            context("when user is not saved") {
                it("reads nil") {
                    expect(sut.currentUser).to(beNil())
                }
            }
        }

        describe("#saveUser") {
            beforeEach() {
                clearUserDefaults()
                let user = Me(id: 2, username: "username", realname: "realname", avatarURL: URL(string: "http://www.allinmobile.co/image.jpg"))
                _ = sut.save(user)
            }

            it("saves the username") {
                expect(sut.string(forKey: userUsernameKey)) == "username"
            }

            it("saves the realname") {
                expect(sut.string(forKey: userRealnameKey)) == "realname"
            }

            it("saves the id") {
                expect(sut.integer(forKey: userIdKey)) == 2
            }
            
            it("saves the avatar") {
                expect(sut.string(forKey: userAvatarKey)) == "http://www.allinmobile.co/image.jpg"
            }
        }
    }
}
