//
//  AnswerView.swift
//  SwiftSampleCode
//
//  Created by Ada Chmielewska on 18.07.2016.
//  Copyright © 2016 All in Mobile. All rights reserved.
//

import UIKit
import Cartography

class AnswerView: UIView {

    @IBOutlet weak var answerTitle: ResizeableTextView! 
    @IBOutlet weak var answerCounter: UILabel!
    
    class func loadForNib() -> AnswerView? {
       return Bundle.main.loadNibNamed("AnswerView", owner: self, options: nil)?.first as? AnswerView
    }
}
