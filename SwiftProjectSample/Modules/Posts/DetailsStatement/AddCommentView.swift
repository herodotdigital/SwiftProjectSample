//
//  AddCommentView.swift
//  SwiftSampleCode
//
//  Created by Ada Chmielewska on 27.06.2016.
//  Copyright © 2016 All in Mobile. All rights reserved.
//

import UIKit

class AddCommentView: UIView {
    @IBOutlet weak var textView: ResizeableTextView!
    @IBOutlet weak var sendButton: UIButton!
    
    @IBOutlet weak var userAvatar: UIImageView! {
        didSet {
            userAvatar.image = R.image.defaultAvatar()
        }
    }
    
    
    @IBAction func sendComment(_ sender: AnyObject) {
        print("tap tap tap tap....")
    }
}
