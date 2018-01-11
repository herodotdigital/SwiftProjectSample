//
//  Statement.swift
//  SwiftSampleCode
//
//  Created by Adam Borek on 13.06.2016.
//  Copyright © 2016 All in Mobile. All rights reserved.
//

import Foundation

struct Post {
    enum State {
        case unvoted
        case voted(answerAtIndex: Int)
    }
    
    let id: Int
    let title: String
    let description: String?
    let owner: UserSnapshot
    let imageURL: URL?
    let creationDate: Date
    let sources: [String]
    var answers: [Answer]
    var state: State

    init(id: Int, title: String, description: String? = nil, owner: UserSnapshot, creationDate: Date, imageURL: URL? = nil, sources: [String], answers: [Answer], state: State) {
        self.id = id
        self.title = title
        self.description = description
        self.owner = owner
        self.creationDate = creationDate
        self.imageURL = imageURL
        self.sources = sources
        self.answers = answers
        self.state = state
    }
}

extension Post {
    func unvotedPost() -> Post {
        var result = self
        if case let .voted(index) = result.state {
            result.answers[index].unvote()
            result.state = .unvoted
        }
        return result
    }
    
    func votedPost(onAnswerAtIndex index: Int) -> Post? {
        var result = self.unvotedPost()
        if index >= 0 && index < result.answers.count {
            result.answers[index].vote()
            result.state = .voted(answerAtIndex: index)
        }
        
        return result
    }
}

extension Post: Hashable {
    var hashValue: Int {
        return id.hashValue ^ title.hashValue
    }
}

func == (lhs: Post, rhs: Post) -> Bool {
    return lhs.id == rhs.id &&
        lhs.title == rhs.title &&
        lhs.state == rhs.state
}

extension Post.State: Equatable {}
func == (lhs: Post.State, rhs: Post.State) -> Bool {
    switch (lhs, rhs) {
    case (.unvoted, .unvoted):
        return true
    case (.voted(let lhsIndex), .voted(let rhsIndex)):
        return lhsIndex == rhsIndex
    default:
        return false
    }
}
