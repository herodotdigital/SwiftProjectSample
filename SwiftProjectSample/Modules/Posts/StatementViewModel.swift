//
//  StatementCellViewModel.swift
//  SwiftSampleCode
//
//  Created by Adam Borek on 13.06.2016.
//  Copyright © 2016 All in Mobile. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import DateTools
import RxOptional
import CocoaLumberjack

private let AgreeRepresentation = "agree"
private let DisagreeRepresentation = "disagree"

class StatementViewModel {
    let didTapAgree = PublishSubject<Void>()
    let didTapDisagree = PublishSubject<Void>()
    
    fileprivate let postVoter: PostVoter
    fileprivate let disposeBag = DisposeBag()
    fileprivate var undoStack: UndoStack<Post>
    fileprivate let _statement: Variable<Post>
    fileprivate let agreeAnswerIndex: Int
    fileprivate let disagreeAnswerIndex: Int
    
    init?(withStatement statement: Post, postVoter: PostVoter = Assembly.Dependencies.postVoter) {
        if statement.answers.count != 2 { return nil }
        guard let agreeIndex = (statement.answers.index { $0.textRepresentation == AgreeRepresentation }),
            let disagreeIndex = (statement.answers.index { $0.textRepresentation == DisagreeRepresentation }) else {
                return nil
        }
        
        self.undoStack = UndoStack(initialElement: statement)
        self.disagreeAnswerIndex = disagreeIndex
        self.agreeAnswerIndex = agreeIndex
        self._statement = Variable(statement)
        self.postVoter = postVoter
        configureOnTapActions()
    }
    
    func configureOnTapActions() {
        let answerOnDidAgree = didTapAgree.do(onNext: { [weak self] in
                self?.doUISideEffectsOnAgreeTap()
            }, onError: nil, onCompleted: nil, onSubscribe: nil, onSubscribed: nil, onDispose: nil)
            .map {
                return self.agree
            }
        
        let answerOnDidDisagree = didTapDisagree
            .do(onNext: { [unowned self] in
                self.doUISideEffectsOnDisagreeTap()
            }, onError: nil, onCompleted: nil, onSubscribe: nil, onSubscribed: nil, onDispose: nil)
            .map {
                return self.disagree
            }
        
        Observable.of(answerOnDidAgree, answerOnDidDisagree)
            .merge()
            .distinctUntilChanged()
            .throttle(0.5, scheduler: MainScheduler.instance)
            .do(onNext: { [unowned self] _ in
                self.undoStack += self.post
            }, onError: nil, onCompleted: nil, onSubscribe: nil, onSubscribed: nil, onDispose: nil)
            .subscribe(onNext: { [unowned self] in
                self.voteOn($0)
            }, onError: nil, onCompleted: nil, onDisposed: nil)
            .addDisposableTo(disposeBag)
    }
    
    fileprivate func doUISideEffectsOnAgreeTap() {
        if let agreedStatement = post.votedPost(onAnswerAtIndex: agreeAnswerIndex) {
            _statement.value = agreedStatement
        }
    }
    
    fileprivate func doUISideEffectsOnDisagreeTap() {
        if let disagreeStatement = post.votedPost(onAnswerAtIndex: disagreeAnswerIndex) {
            _statement.value = disagreeStatement
        }
    }
    
    fileprivate func voteOn(_ answer: Answer) {
        postVoter.vote(onAnswer: answer)
            .subscribe(onNext: nil, onError: { [weak self] _ in
                self?.undoVoteState()
            }, onCompleted: nil, onDisposed: nil)
            .addDisposableTo(self.disposeBag)
    }
    
    fileprivate func undoVoteState() {
        undoStack.undo()
        _statement.value = undoStack.current
    }
}

extension StatementViewModel: PostViewModel {
    var post: Post {
        return _statement.value
    }
    
    fileprivate var agree: Answer {
        return post.answers[agreeAnswerIndex]
    }

    fileprivate var disagree: Answer {
        return post.answers[disagreeAnswerIndex]
    }
    
    var votingState: Observable<VotingView.State> {
        return _statement.asObservable()
            .map { $0.state }
            .map { postState in
                let votingViewState: VotingView.State
                switch postState {
                case .voted(let index) where index == self.agreeAnswerIndex:
                    votingViewState = .agree
                case .voted(let index) where index == self.disagreeAnswerIndex:
                    votingViewState = .disagree
                default:
                    votingViewState = .unvote
                }
                return votingViewState
        }
    }
}

extension StatementViewModel: VotingViewDatasource {
    func textForLabelAbovePercentageBar(atState state: VotingView.State) -> String {
        let agreeVotes = agree.votesCount
        let disagreeVotes = disagree.votesCount
        let totalVotes = agreeVotes + disagreeVotes
        
        switch state {
        case .unvote: return ""
        case .agree:
            assert(totalVotes != 0, "Post at this state has to have at least one vote")
            let percentageOfAgreeVotes = Int(Double(agreeVotes)/Double(totalVotes)*100)
            return "\(percentageOfAgreeVotes)% (from \(totalVotes) \(LocalizedString("VOTES")))"
        case .disagree:
            assert(totalVotes != 0, "Post at this state has to have at least one vote")
            let percentageOfDisagreeVotes = Int(Double(disagreeVotes)/Double(totalVotes)*100)
            return "\(percentageOfDisagreeVotes)% (from \(totalVotes) \(LocalizedString("VOTES")))"
        }
    }
    
    func disagreeAgreeVotesRatio() -> CGFloat {
        let agreeVotes = agree.votesCount
        let disagreeVotes = disagree.votesCount
        let totalVotes = agreeVotes + disagreeVotes
        assert(totalVotes != 0, "Post at this state has to have at least one vote")
        
        return CGFloat(disagreeVotes) / CGFloat(totalVotes)
    }
}

extension StatementViewModel: Hashable {
    var hashValue: Int {
        return _statement.value.hashValue
    }
}

func == (lhs: StatementViewModel, rhs: StatementViewModel) -> Bool {
    return lhs._statement.value == rhs._statement.value
}
