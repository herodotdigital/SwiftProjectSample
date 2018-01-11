//
//  UIViewController+Extensions.swift
//  SwiftSampleCode
//
//  Created by Adam Borek on 21.06.2016.
//  Copyright © 2016 All in Mobile. All rights reserved.
//

import UIKit

extension UIViewController {
    func configureTopBar(accentsColor color: UIColor) {
        navigationController?.navigationBar.tintColor = color
    }
    
    func configureTopBar(title: String, titleColor: UIColor = UIColor.white) {
        self.title = title
        navigationController?.navigationBar.titleTextAttributes = [
            NSForegroundColorAttributeName:titleColor
        ]
    }
}
