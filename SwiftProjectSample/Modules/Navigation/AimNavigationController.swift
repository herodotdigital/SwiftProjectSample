//
//  AimNavigationController.swift
//  SwiftSampleCode
//
//  Created by Ada Chmielewska on 09.06.2016.
//  Copyright © 2016 All in Mobile. All rights reserved.
//

import UIKit

class AimNavigationController: UINavigationController {
    
    @available(*, unavailable)
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureStatusBar()
    }
    
    func configureNavigationBar() {
        navigationBar.backgroundColor = UIColor.projectTomatoColor()
        navigationBar.setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
        navigationBar.shadowImage = UIImage()
        navigationBar.tintColor = UIColor.projectWhiteThreeColor()
    }
    
    func configureStatusBar() {
        let statusBarBackground = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 20))
        statusBarBackground.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
        statusBarBackground.backgroundColor = UIColor.projectTomatoColor()
        self.view.addSubview(statusBarBackground)
    }
    
    
    var wasParentNavigationBarHidden: Bool?
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        wasParentNavigationBarHidden = navigationController?.isNavigationBarHidden
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        guard let wasNavigationBarHidden = wasParentNavigationBarHidden else { return; }
        navigationController?.setNavigationBarHidden(wasNavigationBarHidden, animated: true)
    }
}
