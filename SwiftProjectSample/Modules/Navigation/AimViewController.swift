//
//  AimViewController.swift
//  SwiftSampleCode
//
//  Created by Adam Borek on 30.05.2016.
//  Copyright © 2016 All in Mobile. All rights reserved.
//

import UIKit
import Rswift
import RxSwift
import CocoaLumberjack
import MessageUI

internal class AimViewController: UIViewController {
    fileprivate let _viewDidLoad = PublishSubject<Void>()
    var rx_viewDidLoad: Observable<Void> {
        return _viewDidLoad.asObservable()
    }
    
    fileprivate let _viewWillAppear = PublishSubject<Void>()
    var rx_viewWillApear: Observable<Void> {
        return _viewWillAppear.asObservable()
    }
    
    fileprivate let _viewWillDisappear = PublishSubject<Void>()
    var rx_viewWillDisappear: Observable<Void> {
        return _viewWillDisappear.asObservable()
    }
    
    fileprivate let _viewDidDisappear = PublishSubject<Void>()
    var rx_viewDidDisappear: Observable<Void> {
        return _viewDidDisappear.asObservable()
    }
    
    @available(*, unavailable)
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    init(nibResource: NibResourceType?) {
        super.init(nibName: nibResource?.name, bundle: nibResource?.bundle)
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _viewDidLoad.onNext()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        _viewWillAppear.onNext()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        _viewWillDisappear.onNext()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        _viewDidDisappear.onNext()
    }
    
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        #if DEBUG
        if motion == .motionShake {
            
            if MFMailComposeViewController.canSendMail() {
                let composeVC = MFMailComposeViewController()
                composeVC.mailComposeDelegate = self
                
                // Configure the fields of the interface.
                composeVC.setSubject("Log files")
                composeVC.setMessageBody("Hi. Do you want to report a bug? This is the place to do so. Logs file are also attached", isHTML: false)
                
                let logFilesData = (Assembly.fileLogger.logFileManager.sortedLogFilePaths)
                    .flatMap { filePaths in
                        return NSData(contentsOfFile: filePaths)
                }
                let logFileNames = Assembly.fileLogger.logFileManager.sortedLogFileNames
                
                if let logFileNames = logFileNames {
                    let fileInfos = zip(logFileNames, logFilesData)
                    fileInfos.forEach { name, fileContent in
                        composeVC.addAttachmentData(fileContent as Data, mimeType: "text/plain", fileName: name)
                    }
                }
                
                present(composeVC, animated: true, completion: nil)
            } else {
                let alert = UIAlertController(title: "E-mail", message: "Please configure native mail client", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
                    self?.dismiss(animated: true, completion: nil)
                })
                present(alert, animated: true, completion: nil)
            }
        }
        #endif
    }
}

extension AimViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        dismiss(animated: true, completion: nil)
    }
}

