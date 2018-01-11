//
//  StatementVC.swift
//  SwiftSampleCode
//
//  Created by Ada Chmielewska on 09.06.2016.
//  Copyright © 2016 All in Mobile. All rights reserved.
//

import UIKit
import Cartography
import RxSwift

class  AddStatementVC: AddContentVC {
    
    init(withViewModel viewModel: AddContentViewModel) {
        super.init(withViewModel: viewModel, nib: R.nib.addStatementVC)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTopBar(title: LocalizedString("Statement"), titleColor: UIColor.white)
    }

}
