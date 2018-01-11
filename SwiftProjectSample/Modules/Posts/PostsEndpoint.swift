//
//  PostEndpoint.swift
//  SwiftSampleCode
//
//  Created by Adam Borek on 08.06.2016.
//  Copyright © 2016 All in Mobile. All rights reserved.
//

import Foundation
import CoreLocation
import Moya
import SwiftyJSON

protocol PendingPost {
    var userInputs: PostUserInputs { get set }
    var type: String { get }
    var answersKeys: [String] { get }
}

struct PendingStatement: PendingPost {
    var userInputs: PostUserInputs
    var type: String {
        return "statement"
    }

    var answersKeys: [String] {
        return ["disagree", "agree"]
    }

    init(userInputs: PostUserInputs) {
        self.userInputs = userInputs
    }
}

struct PendingPoll: PendingPost {
    var userInputs: PostUserInputs
    var type: String {
        return "poll"
    }

    var answersKeys: [String] {
        return userInputs.answers
    }

    init(userInputs: PostUserInputs) {
        self.userInputs = userInputs
    }
}

enum PostEndpoint {
    case listOfLocals(user:UserSnapshot, userLocation:CLLocationCoordinate2D)
    case listOfHots(user: UserSnapshot)
    case listOfFollowingPosts(user: UserSnapshot)
    case createNewPost(post:PendingPost, author:UserSnapshot, userLocation:CLLocationCoordinate2D?)
    case vote(user:Me, answer: Answer)
    /**
     *  Represents endpoint for list of posts of given users (`author`) in eyes of a user (`userContext`)
     *  @param author it's an author of posts which list you want to download
     *  @param userContext represents user who looks on the posts list.
     */
    case listOfUserPosts(author: UserSnapshot, userContext: UserSnapshot)
}

extension PostEndpoint: EncodableTargetType {   
    
    var path: String {
        switch self {
        case .vote:
            return "posts/questions/votes"
        default:
            return "posts"
        }
    }

    var method: Moya.Method {
        switch self {
        case .createNewPost, .vote:
            return .post
        default:
            return .get
        }
    }

    var parameters: [String: Any]? {
        switch self {
        case .createNewPost(let post, let author, let location):
            return paramsForCreating(newPost: post, withAuthor: author, atLocation: location)
        case .listOfLocals(let user, let userLocation):
            return paramsForLocalsList(forUser: user, atLocation: userLocation)
        case .listOfFollowingPosts(let user):
            return paramsForFollowingPostList(forUser: user)
        case .listOfHots(let user):
            return paramsForHotsList(forUser: user)
        case .listOfUserPosts(let author, let userContext):
            return paramsForPostsList(whichAuthorIs: author, inEyesOf: userContext)
        case .vote(let me, let answer):
            return paramsForVoting(asUser: me, answer: answer)
        }
    }

    fileprivate func paramsForCreating(newPost post: PendingPost, withAuthor author: UserSnapshot, atLocation location: CLLocationCoordinate2D?) -> [String: Any] {
        var postJSON: [String: Any] = [
            "autor":author.id as Any,
            "title":post.userInputs.title as Any,
            "description":post.userInputs.description as Any,
            "type":post.type as Any,
            "questions":post.answersKeys.map {["value": $0]} as Any
        ]
        if let location = location {
            postJSON["lat"] = String(location.latitude) as Any
            postJSON["lng"] = String(location.longitude) as Any
        }

        if let imageInBase64 = post.userInputs.image?.base64 {
            postJSON["imageFile"] = imageInBase64 as Any
        }

        var urls: [String: String] = [:]
        for (index, source) in post.userInputs.sources.enumerated() {
            urls["\(index)"] = source
        }
        postJSON["urls"] = urls as Any

        return ["post":postJSON as Any]
    }

    fileprivate func paramsForLocalsList(forUser user: UserSnapshot, atLocation location: CLLocationCoordinate2D) -> [String: Any] {
        var paramsForLocals = paramsForHotsList(forUser: user)
        paramsForLocals["type"] = "local" as Any
        paramsForLocals["lat"] = String(location.latitude) as Any
        paramsForLocals["lng"] = String(location.longitude) as Any
        return paramsForLocals
    }

    fileprivate func paramsForFollowingPostList(forUser user: UserSnapshot) -> [String: Any] {
        return [
            "type":"following" as Any,
            "userList":user.id as Any,
            "user":user.id as Any,
            "select":"p.id, p.type, p.title, p.description, p.image, p.createdAt, p.urls, a.id as user_id, a.username, a.picture as autor_picture" as Any,
            "limit":100 as Any
        ]
    }

    fileprivate func paramsForHotsList(forUser user: UserSnapshot) -> [String: Any] {
        return [
            "type":"hot" as Any,
            "user":user.id as Any,
            "select":"p.id, p.type, p.title, p.description, p.image, p.createdAt, p.urls, a.id as user_id, a.username, a.picture as autor_picture" as Any,
            "limit":100 as Any
        ]
    }

    fileprivate func paramsForPostsList(whichAuthorIs author: UserSnapshot, inEyesOf userContext: UserSnapshot) -> [String: Any] {
        return [
            "type":"user" as Any,
            "user":userContext.id as Any,
            "userList":author.id as Any,
            "select":"p.id, p.type, p.title, p.description, p.image, p.createdAt, p.urls, a.id as user_id, a.username, a.picture as autor_picture" as Any,
            "limit":100 as Any
        ]
    }

    fileprivate func paramsForVoting(asUser user: Me, answer: Answer) -> [String: Any] {
        let innerJSON = [
            "user": user.id,
            "postQuestion": answer.id
        ]
        return ["post_question_vote":innerJSON as Any]
    }

    var sampleData: Data {
        switch self {
        case .listOfLocals, .listOfFollowingPosts:
            return sampleDebugData(fromFileNamed: "GET_locals", ofType: "json") as Data
        case .listOfHots:
            return sampleDebugData(fromFileNamed: "GET_hots", ofType: "json") as Data
        case .vote:
            return try! JSON(dictionaryLiteral:("status", "ok")).rawData()
        default:
            return Data()
        }
    }
}
