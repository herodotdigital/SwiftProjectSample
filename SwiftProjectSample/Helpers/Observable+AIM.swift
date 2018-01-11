//
//  Observable+HandyOperator.swift
//  SwiftSampleCode
//
//  Created by Adam Borek on 23.06.2016.
//  Copyright © 2016 All in Mobile. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

extension ObservableType {
    
    func mapToVoid() -> Observable<Void> {
        return map { _ in
            return ()
        }
    }
    
    func catchError(_ selector: @escaping ((Error) -> Error)) -> Observable<Self.E> {
        return catchError { error in
            throw selector(error)
        }
    }
    
    func ignoreErrors() -> Observable<Self.E> {
        return catchError { error in
            return Observable.never()
        }
    }
    
    func previousAndCurrent() -> Observable<(previous: Self.E, current: Self.E)> {
        return Observable.zip(self, self.skip(1)) { (previous:$0, current:$1) }
    }
}

extension ObservableType where E == [String] {
    func filterEmptyStrings() -> Observable<Self.E> {
        return map { originals in
            return originals.filter { return !$0.isEmpty() }
        }
    }
}

infix operator <->

extension Variable {
    func bidirectionalBind(with controlProperty: ControlProperty<Element>) -> Disposable {
        let bindToUIDisposable = self.asObservable()
            .bind(to: controlProperty)
        let bindToVariable = controlProperty
            .subscribe(onNext: {[weak self] n in
                self?.value = n
                }, onCompleted: {
                    bindToUIDisposable.dispose()
            })
        
        return Disposables.create(bindToUIDisposable, bindToVariable)
    }
}

func <-> <T>(property: ControlProperty<T>, variable: Variable<T>) -> Disposable {
    return variable.bidirectionalBind(with: property)
}

