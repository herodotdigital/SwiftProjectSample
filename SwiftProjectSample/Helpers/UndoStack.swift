//
//  UndoStack.swift
//  SwiftSampleCode
//
//  Created by Adam Borek on 25.07.2016.
//  Copyright © 2016 All in Mobile. All rights reserved.
//

import Foundation
import RxSwift

struct UndoStack<Element> {
    fileprivate let initial: Element
    fileprivate var _stack: Variable<[Element]>
    
    init(initialElement: Element) {
        initial = initialElement
        _stack = Variable([])
    }
    
    var rx_stack: Observable<[Element]> {
        return _stack.asObservable()
    }
    
    var current: Element {
        return _stack.value.last ?? initial
    }
    
    var rx_current: Observable<Element> {
        return rx_stack.asObservable().map { $0.last }
            .replaceNilWith(initial)
    }
    
    mutating func undo() {
        if _stack.value.count > 0 {
            _stack.value.removeLast()
        }
    }
    
    mutating func add(_ element: Element) {
        _stack.value.append(element)
    }
}

func += <E>(lhs: inout UndoStack<E>, rhs: E) {
    lhs.add(rhs)
}
