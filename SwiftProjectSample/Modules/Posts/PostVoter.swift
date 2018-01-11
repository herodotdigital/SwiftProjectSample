//
//  PostVoter.swift
//  SwiftSampleCode
//
//  Created by Adam Borek on 27.06.2016.
//  Copyright © 2016 All in Mobile. All rights reserved.
//

import Foundation
import RxSwift
import RxOptional

class PostVoter {
    let apiProvider: RxAPIProvider<PostEndpoint>
    let userPersistanceReader: UserPersistenceReader
    
    init(withAPIProvider provider: RxAPIProvider<PostEndpoint>, userPersistanceReader: UserPersistenceReader) {
        apiProvider = provider
        self.userPersistanceReader = userPersistanceReader
    }
    
    func vote(onAnswer answer: Answer) -> Observable<Void> {
        return userPersistanceReader.rx_currentUser
            .flatMap { me in
                return self.apiProvider.requestJSON(.vote(user: me, answer: answer))
            }.mapToVoid()
    }
}
