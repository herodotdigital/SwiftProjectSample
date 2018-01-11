//
//  WaitingVC.swift
//  SwiftSampleCode
//
//  Created by Adam Borek on 15.06.2016.
//  Copyright © 2016 All in Mobile. All rights reserved.
//

import UIKit
import Rswift

class WaitingVC: AimViewController {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var text: UILabel!
    
    let waitingText: String
    let waitingImage: UIImage
    var wasNavigationBarHidden: Bool?
    
    init(withWaitingText text: String = LocalizedString("Posting..."), waitingImage: UIImageConvertible = R.image.noComments) {
        self.waitingImage = waitingImage.image
        waitingText = text
        super.init(nibResource: R.nib.waitingVC)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = waitingImage
        text.text = waitingText
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        wasNavigationBarHidden = navigationController?.isNavigationBarHidden
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        guard let wasNavigationBarHidden = wasNavigationBarHidden else { return; }
        navigationController?.setNavigationBarHidden(wasNavigationBarHidden, animated: true)
    }
}
