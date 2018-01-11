//
//  CommentsProvider.swift
//  SwiftSampleCode
//
//  Created by Adam Borek on 01.07.2016.
//  Copyright © 2016 All in Mobile. All rights reserved.
//

import Foundation
import Moya
import RxSwift

protocol CommentsProviderType {
    func comments(for statement: Post) -> Observable<[Comment]>
}

class CommentsProvider: CommentsProviderType {
    let apiProvider: RxAPIProvider<CommentsEndpoint>
    init(withApiProvider apiProvider: RxAPIProvider<CommentsEndpoint>) {
        self.apiProvider = apiProvider
    }
    
    func comments(for statement: Post) -> Observable<[Comment]> {
        return apiProvider.requestJSON(.listOfComments(statement: statement))
            .map { json -> [Comment]? in
                return json.array?.flatMap { json in
                    return Comment(withJSON: json)
                }
            }.errorOnNil()
    }
}
