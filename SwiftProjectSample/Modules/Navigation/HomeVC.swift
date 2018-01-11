//
//  HomeVC.swift
//  SwiftSampleCode
//
//  Created by dev on 02.06.2016.
//  Copyright © 2016 All in Mobile. All rights reserved.
//

import UIKit
import Cartography

class HomeVC: AimViewController {
    
    @IBOutlet var tabNavigatorView: AimHomeTabNavigatorView!
    fileprivate let pageViewController: UIPageViewController
    
    let localsVC = Assembly.Controllers.localsVC
    let followingVC = Assembly.Controllers.followingPostsVC
    
    init() {
        pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        super.init(nibResource: R.nib.homeVC)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabNavigatorView()
        addPageViewControllerAsChild()
        showBeginingController()
        tabNavigatorView.rx_selectedIndex.subscribe(onNext: { [unowned self] selectedIndex in
                if selectedIndex == 0 {
                    self.showLocalsVC()
                } else {
                    self.showFollowingVC()
                }
            }, onError: nil, onCompleted: nil, onDisposed: nil)
            .addDisposableTo(rx.disposeBag)
    }
    
    fileprivate func setupTabNavigatorView() {
        tabNavigatorView.padding = 50
        tabNavigatorView.items = [LocalizedString("Local"), LocalizedString("Following")]
        tabNavigatorView.selectedIndex = 0
    }
    
    fileprivate func addPageViewControllerAsChild() {
        pageViewController.willMove(toParentViewController: self)
        addChildViewController(pageViewController)
        view.addSubview(pageViewController.view)
        constrain(pageViewController.view, tabNavigatorView, view) { childView, navigatorView, superview in
            childView.left == superview.left
            childView.right == superview.right
            childView.bottom == superview.bottom
            childView.top == navigatorView.bottom
        }
        pageViewController.didMove(toParentViewController: self)
    }
    
    fileprivate func showLocalsVC() {
        pageViewController.setViewControllers([localsVC], direction: .reverse, animated: true, completion: nil)
    }
    
    fileprivate func showFollowingVC() {
          pageViewController.setViewControllers([followingVC], direction: .forward, animated: true, completion: nil)
    }
    
    fileprivate func showBeginingController() {
        pageViewController.setViewControllers([localsVC], direction: .forward, animated: false, completion: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
}
