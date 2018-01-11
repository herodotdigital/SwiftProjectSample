//
//  MoyaAPIProviderStub.swift
//  SwiftSampleCode
//
//  Created by Adam Borek on 30.06.2016.
//  Copyright © 2016 All in Mobile. All rights reserved.
//

import Foundation
import Moya
import SwiftyJSON
import RxSwift
import Result
@testable import SwiftProjectSample

enum StubResponse {
    case raw(statusCode: Int, data: Data)
    case json(statusCode: Int, json: SwiftyJSON.JSON)
    
    var data: Data {
        switch self {
        case .raw(_, let data):
            return data
        case .json(_, let json):
            return try! json.rawData()
        }
    }
    
    var statusCode: Int {
        switch self {
        case .raw(let statusCode, _):
            return statusCode
        case .json(let statusCode, _):
            return statusCode
        }
    }
}

class StubAPIProvider<Target>: RxAPIProvider<Target> where Target: EncodableTargetType {
    var givenReponse: StubResponse = .json(statusCode: 200, json: JSON([:]))
    var usedTarget: Target?
    
    init() {
        super.init()
    }

    override func request(_ target: Target, completion: @escaping Completion) -> Cancellable {
        let result: Result<Moya.Response, MoyaError> = Result.success(Moya.Response(statusCode: givenReponse.statusCode, data: givenReponse.data))
        usedTarget = target
        completion(result)
        return StubCancellable()
    }
}

private class StubCancellable: Cancellable {
    fileprivate var isCancelled = false

    fileprivate func cancel() {
        isCancelled = true
    }
}
