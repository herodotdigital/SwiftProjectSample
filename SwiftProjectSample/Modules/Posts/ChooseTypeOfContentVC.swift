//
//  ChooseTypeOfContentVC.swift
//  SwiftSampleCode
//
//  Created by Adam Borek on 18.07.2016.
//  Copyright © 2016 All in Mobile. All rights reserved.
//

import UIKit
import RxSwift

class ChooseTypeOfContentVC: AimViewController {
    @IBOutlet fileprivate weak var popup: UIView!
    @IBOutlet fileprivate weak var statementButton: UIButton!
    @IBOutlet fileprivate weak var questionButton: UIButton!
    @IBOutlet fileprivate weak var cancelButton: UIButton!
    @IBOutlet fileprivate weak var statementLabel: UILabel!
    @IBOutlet fileprivate weak var questionLabel: UILabel!
    
    var statementButtonClicked: (() -> Void) = {}
    var questionButtonClicked: (() -> Void) = {}
    var cancelButtonClicked: (() -> Void) = {}
    
    init() {
        super.init(nibResource: R.nib.chooseTypeOfContentVC)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureButtons()
    }
    
    fileprivate func configureButtons() {
        statementLabel.textColor = .projectWhiteFourColor()
        questionLabel.textColor = .projectWhiteFourColor()
        statementLabel.text = LocalizedString("Statement")
        questionLabel.text = LocalizedString("Question")
        configureButtonsTap()
    }
    
    fileprivate func configureButtonsTap() {
        cancelButton.rx.tap.subscribe() { [weak self] _ in
            self?.cancelButtonClicked()
            }.addDisposableTo(rx.disposeBag)
        
        statementButton.rx.tap.subscribe() { [weak self] _ in
            self?.statementButtonClicked()
            }.addDisposableTo(rx.disposeBag)
        
        questionButton.rx.tap.subscribe() { [weak self] _ in
            self?.questionButtonClicked()
            }.addDisposableTo(rx.disposeBag)
    }
    
    override func viewDidLayoutSubviews() {
        popup.ibCircleShape = true
        super.viewDidLayoutSubviews()
    }
}
