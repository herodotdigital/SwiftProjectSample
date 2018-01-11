//
//  TargetType+Defaults.swift
//  SwiftSampleCode
//
//  Created by Adam Borek on 01.07.2016.
//  Copyright © 2016 All in Mobile. All rights reserved.
//

import Foundation
import Moya

extension TargetType {
    var baseURL: URL {
        return Assembly.API.baseURL
    }
    
    var sampleData: NSData {
        return NSData()
    }
    
    var task: Task {
        return .request
    }
    
    var headers: [String : String]? {
        return nil
    }
}

/**
 This functions returns NSData from file with given name and type. It will returns empty NSData() on non-Debug build
 
 - parameter fileName: file name of file you want to read
 - parameter type:     extension of the file - e.g. png
 
 - returns: contests of file
 */
func sampleDebugData(fromFileNamed fileName: String, ofType type: String) -> Data {
    let fileData = Bundle.main.path(forResource: fileName, ofType: type).flatMap { filePath in
        return NSData(contentsOfFile: filePath)
    }
    
    return (fileData ?? NSData()) as Data
}
