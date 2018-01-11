//
//  ImageResizer.swift
//  SwiftSampleCode
//
//  Created by Adam Borek on 20.06.2016.
//  Copyright © 2016 All in Mobile. All rights reserved.
//

import Foundation
import RxSwift

private let usePixelsScale: CGFloat = 1.0
private let usePointsScale: CGFloat = 0.0

class ImageResizer {
    func resize(_ image: UIImage, toFitSize desiredSize: CGSize) -> UIImage? {
        if !isNeededToResize(image: image, desiredSize: desiredSize) {
            return image
        }
        
        let scaleFactor = calculateScaleFactor(image, desiredSize: desiredSize)
        let scaledImage = resize(image, scaleFactor: scaleFactor)
        return scaledImage
    }
    
    fileprivate func isNeededToResize(image: UIImage, desiredSize: CGSize) -> Bool {
        let width = image.size.width
        let height = image.size.height
        
        return width > desiredSize.width || height > desiredSize.height
    }
    
    fileprivate func calculateScaleFactor(_ image: UIImage, desiredSize: CGSize) -> CGFloat {
        let scaleFactor: CGFloat
        if image.size.width > image.size.height {
            scaleFactor = desiredSize.width / image.size.width
        } else {
            scaleFactor = desiredSize.height / image.size.height
        }
        
        return scaleFactor
    }
    
    fileprivate func resize(_ image: UIImage, scaleFactor: CGFloat) -> UIImage {
        let size = image.size.applying(CGAffineTransform(scaleX: scaleFactor, y: scaleFactor))
        UIGraphicsBeginImageContextWithOptions(size, false, usePixelsScale)
        image.draw(in: CGRect(origin: CGPoint.zero, size: size))
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return scaledImage ?? UIImage()
    }
    
    func rx_resize(_ image: UIImage, toFitSize size: CGSize) -> Observable<UIImage?> {
        return Observable.create {[weak self] observe in
            DispatchQueue.global(qos: .default).async {
                let resizedImage = self?.resize(image, toFitSize: size)
                observe.onNext(resizedImage)
                observe.onCompleted()
            }
            return Disposables.create()
        }
    }
}
