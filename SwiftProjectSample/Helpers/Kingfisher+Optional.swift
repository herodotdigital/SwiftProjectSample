//
//  Kingfisher+Optional.swift
//  SwiftSampleCode
//
//  Created by Adam Borek on 01.07.2016.
//  Copyright © 2016 All in Mobile. All rights reserved.
//

import Foundation
import Kingfisher

extension UIImageView {
    func kf_setImage(with url: URL?, loadImageOnFailure imageOnFailure: UIImageConvertible) {
        if let url = url {
            kf_setImage(with: url)
        } else {
            kf.cancelDownloadTask()
            image = imageOnFailure.image
        }
    }
    
    func kf_setImage(with url: URL?, hideOnFailure: Bool = false) {
        if let url = url {
            kf.setImage(with: url)
            isHidden = false
        } else {
            kf.cancelDownloadTask()
            isHidden = true
            image = nil
        }
    }
}
