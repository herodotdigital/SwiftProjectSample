//
//  String+isEmpty.swift
//  SwiftSampleCode
//
//  Created by Adam Borek on 06.06.2016.
//  Copyright © 2016 All in Mobile. All rights reserved.
//

import Foundation
import RxSwift
import RxOptional

extension String {
    public func isEmpty() -> Bool {
        return trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) == ""
    }
}
