//
// Created by Adam Borek on 11.07.2016.
// Copyright (c) 2016 All in Mobile. All rights reserved.
//

import Foundation
import UIKit
import IQKeyboardManagerSwift
import CocoaLumberjack
import Fabric
import Crashlytics

class AppInitializer {
    let window: UIWindow
    let userPersistenceReader: UserPersistenceReader
    let application: UIApplication

    init(window: UIWindow, persistenceReader: UserPersistenceReader, application: UIApplication) {
        self.window = window
        userPersistenceReader = persistenceReader
        self.application = application
    }

    func start() {
        configureGlobalDependencies()

        if !isUserLoggedIn() {
            pushToHome()
            //pushToLogin()
        } else {
            pushToHome()
        }
    }

    fileprivate func configureGlobalDependencies() {
        configureCrashlytics()
        configureKeyboardManager()
        configureLoggers()
        configureStatusBarColor()
    }

    fileprivate func configureCrashlytics() {
//#if RELEASE
        Fabric.with([Crashlytics.self])
//#endif
    }

    fileprivate func configureKeyboardManager() {
        IQKeyboardManager.sharedManager().enable = true
    }

    fileprivate func configureLoggers() {
        showLogsInConsole()
        saveLogsInFile()
    }

    fileprivate func showLogsInConsole() {
        var loggingLevel = DDLogLevel.off

        #if DEBUG
            loggingLevel = DDLogLevel.all
        #endif
        
        if let consoleLogger = DDTTYLogger.sharedInstance {
            consoleLogger.colorsEnabled = true
            DDLog.add(consoleLogger, with: loggingLevel)
        }
    }
    
    fileprivate func saveLogsInFile() {
        let fileLogger = Assembly.fileLogger
        DDLog.add(fileLogger, with: DDLogLevel.error)
    }

    fileprivate func isUserLoggedIn() -> Bool {
        return userPersistenceReader.currentUser != nil
    }

    fileprivate func pushToHome() {
        window.rootViewController = AimTabBarController()
        window.makeKeyAndVisible()
    }
    
    fileprivate func configureStatusBarColor() {
        application.statusBarStyle = .lightContent
    }
}
