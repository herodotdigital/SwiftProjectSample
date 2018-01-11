//
//  VotingView+Rx.swift
//  SwiftSampleCode
//
//  Created by Adam Borek on 27.06.2016.
//  Copyright © 2016 All in Mobile. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift


extension VotingView {
    var rx_state: AnyObserver<VotingView.State> {
        return UIBindingObserver(UIElement:self) { votingView, state in
            votingView.stateOfVoting = state
            }.asObserver()
    }
}

extension VotingView {
    var rx_delegate: RxVotingViewDelegateProxy {
        return RxVotingViewDelegateProxy.proxyForObject(self)
    }
    
    var rx_didTapAgree: Observable<Void> {
        return rx_delegate.didTapAgreeSubject.asObservable()
    }
    
    var rx_didTapDisagree: Observable<Void> {
       return rx_delegate.didTapDisagreeSubject.asObservable()
    }
}

class RxVotingViewDelegateProxy: DelegateProxy, DelegateProxyType, VotingViewDelegate {
    weak fileprivate(set) var votingView: VotingView?
    
    let didTapAgreeSubject = PublishSubject<Void>()
    let didTapDisagreeSubject = PublishSubject<Void>()
    
    required init(parentObject: AnyObject) {
        self.votingView = castOrFatalError(parentObject)
        super.init(parentObject: parentObject)
    }
    
    class func currentDelegateFor(_ object: AnyObject) -> AnyObject? {
        let view: VotingView = castOrFatalError(object)
        return view.delegate
    }
    
    class func setCurrentDelegate(_ delegate: AnyObject?, toObject object: AnyObject) {
        let votingView: VotingView = castOrFatalError(object)
        votingView.delegate = castOptionalOrFatalError(delegate)
    }
    
    func didTapAgree() {
        didTapAgreeSubject.onNext()
        self._forwardToDelegate?.didTapAgree()
    }
    
    func didTapDisagree() {
        didTapDisagreeSubject.onNext()
        self._forwardToDelegate?.didTapDisagree()
    }
}

func castOrFatalError<T>(_ value: Any!) -> T {
    let maybeResult: T? = value as? T
    guard let result = maybeResult else {
        fatalError("Failure converting from \(value) to \(T.self)")
    }
    
    return result
}

func castOptionalOrFatalError<T>(_ value: AnyObject?) -> T? {
    if value == nil {
        return nil
    }
    let v: T = castOrFatalError(value)
    return v
}
