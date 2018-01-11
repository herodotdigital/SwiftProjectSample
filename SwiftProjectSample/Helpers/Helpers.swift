//
//  Helpers.swift
//  SwiftSampleCode
//
//  Created by Adam Borek on 12.05.2016.
//  Copyright © 2016 All in Mobile. All rights reserved.
//

import Foundation
public func LocalizedString(_ key: String, comment: String = "") -> String {
    return NSLocalizedString(key, comment: comment)
}
