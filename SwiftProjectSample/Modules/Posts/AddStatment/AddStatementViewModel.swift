//
//  AddPostViewModel.swift
//  SwiftSampleCode
//
//  Created by Adam Borek on 10.06.2016.
//  Copyright © 2016 All in Mobile. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class AddStatementViewModel: AddContentViewModel {
    
    override func receiveUserInputs() -> PostUserInputs {
        let sources = takeSourceFromDelegateBecauseIDontKnowHowToMakeItObservable()
        return PostUserInputs(title: title.value, description: explanation.value, sources: sources, image: image.value, answers: [])
    }
}
