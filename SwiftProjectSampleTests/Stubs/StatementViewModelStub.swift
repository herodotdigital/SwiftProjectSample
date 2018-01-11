//
//  StatementViewModel.swift
//  SwiftSampleCode
//
//  Created by Adam Borek on 04.07.2016.
//  Copyright © 2016 All in Mobile. All rights reserved.
//

import Foundation
@testable import SwiftProjectSample
class StatementViewModelStub: StatementViewModel {
    init() {
        super.init(withStatement: FactoryGirl.Post.statement, postVoter: Assembly.Dependencies.postVoter)!
    }
}
