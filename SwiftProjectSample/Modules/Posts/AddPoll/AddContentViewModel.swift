//
//  AddContentViewModel.swift
//  SwiftSampleCode
//
//  Created by Ada Chmielewska on 17.07.2016.
//  Copyright © 2016 All in Mobile. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

protocol AddContentViewModelDelegate: class {
    func sourcesForThePost() -> [String]
}

struct PostUserInputs {
    let title: String
    let description: String
    let sources: [String]
    var image: UIImage?
    var answers: [String]
    
    init(title: String, description: String = "", sources: [String] = [], image: UIImage? = nil, answers: [String] = []) {
        self.title = title
        self.description = description
        self.sources = sources
        self.image = image
        self.answers = answers
    }
}

class  AddContentViewModel {
    //inputs
    let title = Variable<String>("")
    let postOwnername = Variable<String>("")
    let image = Variable<UIImage?>(nil)
    let explanation = Variable<String>("")
    let sendTaps = PublishSubject<Void>()
    //outputs
    let disposeBag = DisposeBag()
    fileprivate var validatedTitle: Driver<Bool>?
    fileprivate (set) var titleCount: Driver<String>?
    var possibleToCreatePost: Observable<Bool> = Observable.just(false)
    
    let loadingState: Variable<DataLoadState<Void>> = Variable(DataLoadState.initial)
    //dependencies
    let userPersistenceReader: UserPersistenceReader
    let postUploader: PostUploader
    var maximumTitleCount = 140
    weak var delegate: AddContentViewModelDelegate?
    
    init(withPostUploader postUploader: PostUploader, userPersistenceReader: UserPersistenceReader) {
        self.postUploader = postUploader
        self.userPersistenceReader = userPersistenceReader
        configureRx()
    }
    
    
    func configureRx() {
        configureTitleOutputs()
        configureOwnerOutputs()
        configureOnSendButtonPressedBehaviour()
    }
    
    fileprivate func configureTitleOutputs() {
        titleCount = title.asDriver()
            .map { return $0.count }
            .map { [unowned self] count in
                return "\(count)/\(self.maximumTitleCount)"
        }
        let validatedTitle = title.asDriver()
            .containsEqualyOrLessCharactersThan(140)
            .distinctUntilChanged()
        possibleToCreatePost = validatedTitle.asObservable()
        self.validatedTitle = validatedTitle
    }
    
    
    fileprivate func configureOwnerOutputs() {
        userPersistenceReader.rx_currentUser
            .map { me  in
                return me.username
            }.bind(to: postOwnername).addDisposableTo(disposeBag)
    }
    
    func configureOnSendButtonPressedBehaviour() {
        sendTaps
            .do(onNext: { [unowned self] in
                self.setOnLoading()
                }, onError: nil, onCompleted: nil, onSubscribe: nil, onSubscribed: nil, onDispose: nil)
            .flatMap { [unowned self] in
                return self.createPostOnTheServer()
                    .asDriver(onErrorJustReturn: DataLoadState.failed(messeage: LocalizedString("Something went wrong")))
            }
            .bind(to: loadingState)
            .addDisposableTo(disposeBag)
    }
    
    fileprivate func setOnLoading() {
        loadingState.value = DataLoadState.loading
    }
    
    fileprivate func createPostOnTheServer() -> Observable<DataLoadState<Void>> {
        return postUploader.upload(receiveUserInputs())
            .map { _ in
                return DataLoadState.loaded()
        }
        
    }
    
    func receiveUserInputs() -> PostUserInputs {
        fatalError("abstract method")
    }
    
    func takeSourceFromDelegateBecauseIDontKnowHowToMakeItObservable() -> [String] {
        return delegate?.sourcesForThePost() ?? []
    }
    
    
}

extension SharedSequenceConvertibleType where SharingStrategy == DriverSharingStrategy, E == String {
    func containsEqualyOrLessCharactersThan(_ count: Int) -> Driver<Bool> {
        return self.map { text in
            let currentCount = text.count
            return currentCount > 2 && currentCount <= count
        }
    }
}
