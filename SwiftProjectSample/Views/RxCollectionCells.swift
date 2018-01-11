//
//  RxCollectionCells.swift
//  SwiftSampleCode
//
//  Created by Adam Borek on 13.06.2016.
//  Copyright © 2016 All in Mobile. All rights reserved.
//

import UIKit
import NSObject_Rx
import RxSwift

class RxTableViewCell: UITableViewCell {
    var reusableDisposeBag = DisposeBag()
    override func prepareForReuse() {
        reusableDisposeBag = DisposeBag()
        super.prepareForReuse()
    }
}
