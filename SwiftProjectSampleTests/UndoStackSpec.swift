//
//  UndoStackSpec.swift
//  SwiftSampleCode
//
//  Created by Adam Borek on 25.07.2016.
//  Copyright © 2016 All in Mobile. All rights reserved.
//

import Foundation
import RxSwift
import RxNimble
import Nimble
import Quick
@testable import SwiftProjectSample

class UndoStackSpec: QuickSpec {
    override func spec() {
        describe("UndoStack") {
            var sut: UndoStack<Int>!
            beforeEach() {
                sut = UndoStack(initialElement: 0)
            }
            it("current element is the first element in the stack") {
                sut.add(1)
                sut.add(2)
                sut.add(3)
                expect(sut.current) == 3
            }
            
            it("notifies about current element") {
                sut.add(1)
                expect(sut.rx_current) == 1
            }
            
            context("after undo state") {
                beforeEach() {
                    sut.add(1)
                    sut.add(2)
                    sut.undo()
                }
                
                it("current element is 1") {
                    expect(sut.current) == 1
                }
                
                context("when there is only initial element in stack") {
                    beforeEach {
                        sut = UndoStack(initialElement: 0)
                        sut.undo()
                    }
                    
                    it("set initial element as current one") {
                        expect(sut.current) == 0
                    }
                }
            }
        }
    }
}
