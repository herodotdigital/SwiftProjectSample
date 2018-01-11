//
//  APIProvider.swift
//  SwiftSampleCode
//
//  Created by Adam Borek on 30.06.2016.
//  Copyright © 2016 All in Mobile. All rights reserved.
//

import Foundation
import RxSwift
import Moya
import Result
import SwiftyJSON

struct APIError: Swift.Error {
    let json: JSON
    let message: String
    
    init(json: JSON, message: String = "") {
        self.json = json
        self.message = message
    }
}

protocol EncodableTargetType: TargetType {
    var parameterEncoding: Moya.ParameterEncoding { get }
}

class RxAPIProvider<Target>: RxMoyaProvider<Target> where Target: EncodableTargetType {

    override public init(endpointClosure:@escaping EndpointClosure = MoyaProvider.defaultEndpointMapping,
                         requestClosure: @escaping RequestClosure = MoyaProvider.defaultRequestMapping,
                         stubClosure: @escaping StubClosure = MoyaProvider.neverStub,
                         manager: Manager = RxMoyaProvider<Target>.defaultAlamofireManager(),
                         plugins: [PluginType] = [],
                         trackInflights: Bool = false) {
        super.init(endpointClosure: endpointClosure, requestClosure: requestClosure, stubClosure: stubClosure, manager: manager, plugins: plugins, trackInflights: trackInflights)
    }
    
    func requestJSON(_ token: Target) -> Observable<SwiftyJSON.JSON> {
        return request(token)
            .validate(statusCode: 200..<300)
            .mapToJSON()
    }
}

private extension Swift.Error {
    func toAPIError() -> Swift.Error {
        if let error = self as? Moya.MoyaError {
            let data = error.response?.data
            let json = JSON(data ?? Data())
            return APIError(json: json)
        }
        
        return self
    }
}

private extension ObservableType where E == Moya.Response {
    func validate<S: Sequence>(statusCode acceptableStatusCode: S) -> Observable<Self.E> where S.Iterator.Element == Int {
        return map { response in
            if !acceptableStatusCode.contains(response.statusCode) {
                let data = response.data
                throw APIError(json: try JSON(data: data))
            }
            
            return response
        }
    }
    
    func mapToJSON() -> Observable<JSON> {
        return mapJSON()
            .map(JSON.init)
    }
}

extension EncodableTargetType {
    var parameterEncoding: Moya.ParameterEncoding {
        switch self.method {
        case .get, .delete:
            return URLEncoding.default
        default:
            return JSONEncoding.default
        }
    }
    
    var multipartBody: [MultipartFormData]? {
        return nil
    }
}
