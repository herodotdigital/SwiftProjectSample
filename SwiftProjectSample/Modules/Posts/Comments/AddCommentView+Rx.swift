//
//  AddCommentView+Rx.swift
//  SwiftSampleCode
//
//  Created by Adam Borek on 05.07.2016.
//  Copyright © 2016 All in Mobile. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

extension AddCommentView {
    var rx_text: ControlProperty<String> {
        return textView.rx.text.orEmpty
    }
    
    var rx_sendTap: ControlEvent<Void> {
        return sendButton.rx.tap
    }
}
