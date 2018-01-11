//
//  DataLoadState.swift
//  SwiftSampleCode
//
//  Created by Adam Borek on 11.06.2016.
//  Copyright © 2016 All in Mobile. All rights reserved.
//

import Foundation

enum DataLoadState<T> {
    case initial
    case loading
    case failed(messeage:String?)
    case loaded(T)
}
