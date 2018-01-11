//
//  PostParser.swift
//  SwiftSampleCode
//
//  Created by Adam Borek on 29.06.2016.
//  Copyright © 2016 All in Mobile. All rights reserved.
//

import Foundation
import SwiftyJSON

private let kIdKey = "id"
private let kTitleKey = "title"
private let kDescriptionKey = "description"
private let kSourcesKey = "urls"

protocol PostParser {
    func parse(collectionResponse response: JSON) throws -> [Post]
}

struct PostParserError: Error {
    let message: String?
    let json: JSON?
    
    init(message: String? = nil, json: JSON = nil) {
        self.message = message
        self.json = json
    }
}

class JSONPostParser: PostParser {
    func parse(collectionResponse response: JSON) throws -> [Post] {
        guard let posts = response.array?.parseToPosts() else {
            throw PostParserError(message: "Cannot parse the response", json: response)
        }
        
        return posts
    }
}

private extension Collection where Iterator.Element == JSON {
    func parseToPosts() -> [Post]? {
        return flatMap { json in
            guard let id = json[kIdKey].int,
                let title = json[kTitleKey].string,
                let createdDate = parseDate(from: json),
                let owner = MinimalUser(withJSON: json["autor"]),
                let answersAndState = parseAnswers(from: json)
                else { return nil }
            
            let description = json[kDescriptionKey].string
            let imageURL = Assembly.API.parseImageURL(from: json)
            let sources = parseSources(from: json)
            
            let post = Post(id: id, title: title, description: description, owner: owner, creationDate: createdDate as Date, imageURL: imageURL, sources: sources, answers: answersAndState.answers, state: answersAndState.state)
            return post
        }
    }
    
    func parseDate(from json: JSON) -> NSDate? {
        guard let dateLiteral = json["created_at"].string else { return nil }
        return NSDate(string: dateLiteral, formatString: Assembly.API.dateFormat)
    }
    
    func parseSources(from json: JSON) -> [String] {
        guard let sourcesArray = json[kSourcesKey].array else { return [] }
        return sourcesArray.flatMap { element in
            return element.string
        }
    }
    
    
    typealias AnswerAndVote = (answer: Answer, voted: Bool)
    func parseAnswers(from json: JSON) -> (answers: [Answer], state: Post.State)? {
        return json["questions"].array
            .flatMap(parseToAnswers)
            .flatMap(makeSureThatThereAreAtLeastTwoAnswers)
            .flatMap(makeSureThatThereIsOnlyOneAnswerVoted)
            .flatMap(determineTheStateOfPost)
    }
    
    func parseToAnswers(_ json: [JSON]) -> [AnswerAndVote] {
        return json.flatMap { json in
            guard let answer = Answer(withJSON: json), let voted = json["user_vote"].bool else {
                return nil
            }
            return (answer: answer, voted: voted)
        }
    }
    
    func makeSureThatThereAreAtLeastTwoAnswers(_ answers: [AnswerAndVote]) -> [AnswerAndVote]? {
        if answers.count > 1 {
            return answers
        } else {
            return nil
        }
    }
    
    func sortInGoodOrder(_ answers: [Answer]) -> [Answer] {
        if isStatementAnswers(answers) {
            return makeSureThatDisagreeIsOnFirstPlace(answers)
        } else {
            return answers
        }
    }
    
    func makeSureThatDisagreeIsOnFirstPlace(_ answers: [Answer]) -> [Answer] {
        return answers.sorted { $0.0.textRepresentation == "disagree" }
    }
    
    
    func isStatementAnswers(_ answers: [Answer]) -> Bool {
        if answers.count != 2 {
            return false
        }
        
        let answersTextRepresentation = Set(answers.map {
            $0.textRepresentation
        })
        let statementPossibleAnswers = Set(arrayLiteral: "disagree", "agree")
        return statementPossibleAnswers.isSubset(of: answersTextRepresentation)
    }
    
    func makeSureThatThereIsOnlyOneAnswerVoted(_ answers: [AnswerAndVote]) -> [AnswerAndVote]? {
        if isOnlyOneAnswerAlreadyVoted(answers) {
            return answers
        } else {
            return nil
        }
    }
    
    func determineTheStateOfPost(_ answers: [AnswerAndVote]) -> (answers: [Answer], postState: Post.State)? {
        
        let votedAnswerIndex = answers.index { $0.voted == true }
        
        let state: Post.State
        if let votedAnswerIndex = votedAnswerIndex {
            state = .voted(answerAtIndex:votedAnswerIndex)
        } else {
            state = .unvoted
        }
        
        return (answers: answers.map { $0.answer}, postState: state)
    }
    
    func isOnlyOneAnswerAlreadyVoted(_ answers: [AnswerAndVote]) -> Bool {
        let votedAnswers = answers.reduce(0) { accumulator, answer in
            return accumulator + (answer.voted ? 1 : 0)
        }
        return votedAnswers < 2
    }
    
    func filterOnlyStatementAnswers(_ answer: Answer) -> Bool {
        let value = answer.textRepresentation
        return value == "agree" || value == "disagree"
    }
}

extension Collection {
    func find(_ predicate: (Self.Iterator.Element) -> Bool) -> Self.Iterator.Element? {
        return index(where: predicate).map({self[$0]})
    }
}
