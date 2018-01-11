//
//  RxNimble+Driver.swift
//  SwiftSampleCode
//
//  Created by Adam Borek on 12.06.2016.
//  Copyright © 2016 All in Mobile. All rights reserved.
//

import Foundation
import RxNimble
import Nimble
import RxCocoa

public func equalFirst<T: Equatable, O: SharedSequenceConvertibleType>(_ expectedValue: T?) -> MatcherFunc<O> where O.E == T {
    return MatcherFunc { actualExpression, failureMessage in
        
        failureMessage.postfixMessage = "equal <\(String(describing: expectedValue))>"
        let actualValue = try actualExpression.evaluate()?.toBlocking().first()
        failureMessage.actualValue = "\(String(describing: actualValue))"
        
        let matches = actualValue == expectedValue
        return matches
    }
}

public func equalFirst<T: Equatable, O: SharedSequenceConvertibleType>(_ expectedValue: T?) -> MatcherFunc<O> where O.E == T? {
    return MatcherFunc { actualExpression, failureMessage in
        
        failureMessage.postfixMessage = "equal <\(String(describing: expectedValue))>"
        let actualValue = try actualExpression.evaluate()?.toBlocking().first()
        failureMessage.actualValue = "\(String(describing: actualValue))"
        
        switch actualValue {
        case .none:
            return expectedValue == nil
        case .some(let wrapped):
            return wrapped == expectedValue
        }
    }
}

public func ==<T: Equatable, O: SharedSequenceConvertibleType>(lhs: Expectation<O>, rhs: T?) where O.E == T {
    lhs.to( equalFirst(rhs) )
}

public func ==<T: Equatable, O: SharedSequenceConvertibleType>(lhs: Expectation<O>, rhs: T?) where O.E == Optional<T> {
    lhs.to( equalFirst(rhs) )
}
