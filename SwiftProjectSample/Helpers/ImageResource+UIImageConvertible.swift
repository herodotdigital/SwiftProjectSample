//
//  ImageResource+UIImageConvertible.swift
//  SwiftSampleCode
//
//  Created by Adam Borek on 24.05.2016.
//  Copyright © 2016 All in Mobile. All rights reserved.
//

import UIKit
import Rswift

extension ImageResource : UIImageConvertible {
    var image: UIImage {
        guard let image = UIImage(named: name) else {
            assert(false, "Image with name \"\(name)\" does not exist")
            return UIImage()
        }

        return image
    }
}

public func == (lhs: ImageResource, rhs: ImageResource) -> Bool {
    return lhs.name == rhs.name &&
    lhs.bundle == rhs.bundle
}
