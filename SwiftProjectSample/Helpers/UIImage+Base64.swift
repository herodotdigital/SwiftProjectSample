//
//  UIImage+Base64.swift
//  SwiftSampleCode
//
//  Created by Adam Borek on 01.07.2016.
//  Copyright © 2016 All in Mobile. All rights reserved.
//

import UIKit.UIImage
import Foundation

extension UIImage {
    var base64: String? {
        return UIImagePNGRepresentation(self)
            .flatMap { imageData in
                return imageData.base64EncodedString(options: .endLineWithLineFeed)
        }
    }
}
