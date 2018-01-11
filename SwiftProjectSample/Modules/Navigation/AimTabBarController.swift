//
//  AimTabBarController.swift
//  SwiftSampleCode
//
//  Created by dev on 02.06.2016.
//  Copyright © 2016 All in Mobile. All rights reserved.
//

import UIKit
import RxSwift

class AimTabBarController: UITabBarController {
    let addPostViewControllerBookmark = UIViewController()
    let addPostTap = PublishSubject<Void>()

    override func viewDidLoad() {
        super.viewDidLoad()
        viewControllers = createChildControllers()
        tabBar.barTintColor = UIColor.projectWhiteThreeColor()
        tabBar.tintColor = UIColor.projectTomatoColor()
        navigationItem.hidesBackButton = true
        navigationController?.isNavigationBarHidden = true
        delegate = self
        handleAddPostTap()
    }

    fileprivate func createChildControllers() -> [UIViewController] {
        let homeVC = HomeVC()
        makeViewControllerNotCoverableByTabBar(homeVC)
        let homeWithNavigation = homeVC.wrapedWithNavigationControllerToHaveNavigationBar()
        homeVC.tabBarItem = UITabBarItem(image: R.image.tabbar_home_normal)

        let hotVC = Assembly.Controllers.hotsVC.wrapedWithNavigationControllerToHaveNavigationBar()
        hotVC.setAimNavigationBarTitleSettings()
        hotVC.navigationBar.topItem?.title = LocalizedString("Hots")
        hotVC.tabBarItem = UITabBarItem(image: R.image.tabbar_hot_normal)

        addPostViewControllerBookmark.tabBarItem = UITabBarItem(image: R.image.tabbar_add_normal)

        let searchVC = UIViewController() //not available inside this sample
        searchVC.tabBarItem = UITabBarItem(image: R.image.tabbar_search_normal)

        let profileVC = UIViewController() //not available inside this sample
        profileVC.tabBarItem = UITabBarItem(image: R.image.tabbar_profile_normal)

        return [homeWithNavigation, hotVC, addPostViewControllerBookmark, searchVC, profileVC]
    }

    fileprivate func configureChildControllers(_ controllers: [UIViewController]) {
        controllers.forEach() { controller in
            controller.edgesForExtendedLayout = UIRectEdge()
        }
    }

    fileprivate func makeViewControllerNotCoverableByTabBar(_ viewController: UIViewController) {
        viewController.edgesForExtendedLayout = UIRectEdge()
    }

    fileprivate func handleAddPostTap() {
        addPostTap.subscribe(onNext: {  [weak self] in
            self?.presentChooseContentTypeScreen()
        }, onError: nil, onCompleted: nil, onDisposed: nil)
        .addDisposableTo(rx.disposeBag)
    }

    fileprivate func presentChooseContentTypeScreen() {
        let chooseTypeVC = ChooseTypeOfContentVC()

        chooseTypeVC.cancelButtonClicked = { [weak self] in
            self?.dismiss(animated: true, completion: nil)
        }
        chooseTypeVC.statementButtonClicked = { [weak self] in
            let addStatementVC = Assembly.Controllers.addStatementVC
            self?.dismiss(animated: true) {
                self?.present(addStatementVC.wrapedWithNavigationControllerToHaveNavigationBar(), animated: true, completion: nil)
            }
        }
        chooseTypeVC.questionButtonClicked = { [weak self] in
            let addPollVC = Assembly.Controllers.addPollVC
            self?.dismiss(animated: true) {
                self?.present(addPollVC.wrapedWithNavigationControllerToHaveNavigationBar(), animated: true, completion: nil)
            }
        }

        chooseTypeVC.dontCoverPresentingControllerWhilePresenting()
        present(chooseTypeVC, animated: true, completion: nil)
    }
}

extension AimTabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if isAddPostControllerSelected(controller: viewController) {
            DispatchQueue.main.async {
                self.addPostTap.onNext()
            }
            return false
        }

        return true
    }

    fileprivate func isAddPostControllerSelected(controller: UIViewController) -> Bool {
        return controller === addPostViewControllerBookmark
    }
}

private extension UIViewController {
    func wrapedWithNavigationControllerToHaveNavigationBar() -> AimNavigationController {
        return AimNavigationController(rootViewController: self)
    }

    func dontCoverPresentingControllerWhilePresenting() {
        modalPresentationStyle = .custom
    }
}

private extension UINavigationController {
    func setAimNavigationBarTitleSettings() {
        self.navigationBar.setTitleVerticalPositionAdjustment(2, for: .default)
        self.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont.systemFont(ofSize: 18, weight: UIFontWeightMedium),
                                                  NSForegroundColorAttributeName: UIColor.projectWhiteThreeColor()]
    }
}

extension UITabBarItem {
    convenience init(image: UIImageConvertible) {
        self.init(title: nil, image: image.image, selectedImage: image.image)
        imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
    }
}
