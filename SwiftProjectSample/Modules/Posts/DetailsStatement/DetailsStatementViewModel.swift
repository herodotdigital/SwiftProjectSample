//
//  DetailsStatementViewModel.swift
//  SwiftSampleCode
//
//  Created by Adam Borek on 04.07.2016.
//  Copyright © 2016 All in Mobile. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxDataSources

protocol DetailsStatementViewModelDelegate: class {
    func didRefreshComments()
    func didAdd(comment: CommentViewModel, at index: Int)
}
class DetailsStatementViewModel {
    let statementViewModel: StatementViewModel
    weak var delegate: DetailsStatementViewModelDelegate?
    
    fileprivate (set) var comments: [CommentViewModel] = []
    
    fileprivate let me: Me?
    
    let newComment = Variable("")
    var newCommentAuthorAvatar: URL? {
        return me?.avatarURL
    }
    
    fileprivate let _loading = Variable(false)
    var loading: Observable<Bool> {
        return _loading.asObservable()
    }

    let canSendComment: Observable<Bool>
    
    fileprivate let commentsService: CommentsService
    fileprivate let disposeBag = DisposeBag()
    fileprivate var statement: Post {
        return statementViewModel.post
    }
    
    fileprivate let _sendButtonTap = PublishSubject<Void>()
    var sendButtonTap: AnyObserver<Void> {
        return _sendButtonTap.asObserver()
    }
    
    init(withStatementViewModel viewModel: StatementViewModel, commentsService: CommentsService, userReader: UserPersistenceReader) {
        self.statementViewModel = viewModel
        self.commentsService = commentsService
        me = userReader.currentUser
        
        canSendComment = newComment.asObservable()
            .map { $0.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) }
            .map { $0.count > 0 }
        
        _sendButtonTap
            .do(onNext: { [unowned self] in
                self._loading.value = true
            }, onError: nil, onCompleted: nil, onSubscribe: nil, onSubscribed: nil, onDispose: nil)
            .withLatestFrom(newComment.asObservable())
            .map { [unowned self] in PendingComment(comment: $0, post: self.statement) }
            .flatMap { [unowned self] in
                self.commentsService.upload($0)
                    .do(onNext: nil, onError: { [unowned self] _ in
                        self._loading.value = false
                    }, onCompleted: nil, onSubscribe: nil, onSubscribed: nil, onDispose: nil)
                    .ignoreErrors()
            }.map (CommentViewModel.init)
            .do(onNext: { comment in
                self.comments.append(comment)
                self._loading.value = false
            }, onError: nil, onCompleted: nil, onSubscribe: nil, onSubscribed: nil, onDispose: nil)
            .subscribe(onNext: { [unowned self] comment in
                let lastIndex = self.comments.count - 1
                self.newComment.value = ""
                self.delegate?.didAdd(comment: comment, at: lastIndex)
            }, onError: nil, onCompleted: nil, onDisposed: nil)
            .addDisposableTo(disposeBag)
        
        commentsService.comments(for: statement)
            .map { comments in
                return comments.map(CommentViewModel.init)
            }.subscribe(onNext: { [unowned self] in
                self.comments += $0
                self.delegate?.didRefreshComments()
            }, onError: nil, onCompleted: nil, onDisposed: nil)
            .addDisposableTo(disposeBag)
    }
}

extension DetailsStatementViewModel: Hashable, IdentifiableType {
    typealias Identity = DetailsStatementViewModel
    
    var identity: Identity {
        return self
    }
    
    var hashValue: Int {
        return 1
    }
}

func == (lhs: DetailsStatementViewModel, rhs: DetailsStatementViewModel) -> Bool {
    return true
}
