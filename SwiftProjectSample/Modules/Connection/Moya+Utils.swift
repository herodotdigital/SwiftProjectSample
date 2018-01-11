//
//  Moya+Utils.swift
//  SwiftSampleCode
//
//  Created by Adam Borek on 30.06.2016.
//  Copyright © 2016 All in Mobile. All rights reserved.
//

import Foundation
import Moya

struct MoyaUtils {
    static func endpointClosure<T: EncodableTargetType>(withAuthorizationToken authorizationToken: String) -> ((T) -> Endpoint<T>) {
        return { target in
            let endpoint = Endpoint<T>(url: url(for: target),
                                       sampleResponseClosure: { .networkResponse(200, target.sampleData) },
                                       method: target.method,
                                       parameters: target.parameters,
                                       parameterEncoding: target.parameterEncoding,
                                       httpHeaderFields: target.headers)
            return endpoint.adding(newHTTPHeaderFields: ["Authorization":authorizationToken])
                            .adding(newHTTPHeaderFields: ["X-Accept-Version":"v1"])
        }
    }
    
    static func url<T: TargetType>(for target: T) -> String {
        return URL(string: target.path, relativeTo: target.baseURL)?.absoluteString ?? ""
    }
}
