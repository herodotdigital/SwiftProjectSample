//
//  StubPostsParser.swift
//  SwiftSampleCode
//
//  Created by Adam Borek on 29.06.2016.
//  Copyright © 2016 All in Mobile. All rights reserved.
//

import Foundation
import RxSwift
import RxNimble
import Nimble
import Quick
import SwiftyJSON
@testable import SwiftProjectSample

class StubPostsParser: PostParser {
    var givenStatements: [Post]?
    func parse(collectionResponse response: JSON) throws -> [Post] {
        return givenStatements ?? []
    }
}
