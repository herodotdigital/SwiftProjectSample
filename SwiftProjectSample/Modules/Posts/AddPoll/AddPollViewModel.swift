//
//  AddPollViewModel.swift
//  SwiftSampleCode
//
//  Created by Ada Chmielewska on 17.07.2016.
//  Copyright © 2016 All in Mobile. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

class AddPollViewModel: AddContentViewModel {
    
    let answers = [Variable(""), Variable(""), Variable(""), Variable(""), Variable("")]
    var answersCount: [Driver<String>] = []
    
    let maximumAnswerTextCount = 80
    let maximumAnswers: Int
    
    override init(withPostUploader postUploader: PostUploader, userPersistenceReader: UserPersistenceReader) {
        maximumAnswers = answers.count
        super.init(withPostUploader: postUploader, userPersistenceReader: userPersistenceReader)
    }
    
    override func configureRx() {
        super.configureRx()
        configureAnswers()
    }
    
    func configureAnswers() {
        answersCount = answers.map { answerCount(for: $0)}
        let filteredAnswerValues = Observable.combineLatest(answers.map{ $0.asObservable() }) { $0 }
            .filterEmptyStrings()
        possibleToCreatePost = Observable.combineLatest(possibleToCreatePost, filteredAnswerValues) { (superConditions, filteredAnswerValues) in
            return superConditions && filteredAnswerValues.count > 1 && filteredAnswerValues.elementsHasLessOrEqualChars(than: self.maximumAnswerTextCount)
        }
    }
    
    fileprivate func answerCount(for variable: Variable<String>) -> Driver<String> {
        return variable.asDriver()
            .map { return $0.count }
            .map { [unowned self] count in
                return "\(count)/\(self.maximumAnswerTextCount)"
        }
    }
    
    override func receiveUserInputs() -> PostUserInputs {
        let sources = takeSourceFromDelegateBecauseIDontKnowHowToMakeItObservable()
        return PostUserInputs(title: title.value, description: explanation.value, sources: sources, image: image.value, answers: notEmptyAnswers)
    }
    
    var notEmptyAnswers: [String] {
        return answers.filter { !$0.value.isEmpty() }
        .map { $0.value }
    }
}

private extension Collection where Iterator.Element == String {
 
    func elementsHasLessOrEqualChars(than amount: Int) -> Bool {
        return reduce(true, { (previous, current) -> Bool in
            return previous && current.count <= amount
        })
    }
}
