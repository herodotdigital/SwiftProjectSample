//
//  DetailsStatementVC.swift
//  SwiftSampleCode
//
//  Created by Ada Chmielewska on 15.06.2016.
//  Copyright © 2016 All in Mobile. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import NSObject_Rx
import RxOptional
import SafariServices
import IQKeyboardManagerSwift

private enum DetailsStatementSections: Int {
    case details = 0
    case comments = 1
    
    var position: Int {
        return self.rawValue
    }
}

@objc(DetailsStatementVC)
class DetailsStatementVC: AimViewController {
    fileprivate let viewModel: DetailsStatementViewModel
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.register(R.nib.detailsStatementCell)
            tableView.register(R.nib.commentCell)
            tableView.bounces = false
            tableView.estimatedRowHeight = 50
            tableView.separatorStyle = .none
            tableView.allowsSelection = false
            tableView.dataSource = self
            tableView.delegate = self
            tableView.rowHeight = UITableViewAutomaticDimension
        }
    }
    @IBOutlet weak var commentView: AddCommentView!
    @IBOutlet weak var sendingPostIndicator: UIActivityIndicatorView!
    @IBOutlet weak var sendCommentButton: UIButton!
    
    init(viewModel: DetailsStatementViewModel) {
        self.viewModel = viewModel
        super.init(nibResource: R.nib.detailsStatementVC)
        self.viewModel.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        commentView.userAvatar.kf_setImage(with: viewModel.newCommentAuthorAvatar, loadImageOnFailure: R.image.defaultAvatar)
        commentView.rx_sendTap.bind(to: viewModel.sendButtonTap).addDisposableTo(rx.disposeBag)
        viewModel.newComment.bidirectionalBind(with: commentView.rx_text).addDisposableTo(rx.disposeBag)
        viewModel.canSendComment.bind(to: sendCommentButton.rx.isEnabled).addDisposableTo(rx.disposeBag)
        viewModel.loading.bind(to: sendCommentButton.rx.isHidden).addDisposableTo(rx.disposeBag)
        viewModel.loading.bind(to: sendingPostIndicator.rx.isAnimating).addDisposableTo(rx.disposeBag)
        
        automaticallyAdjustsScrollViewInsets = false
    }
    
    fileprivate func cell(for details: StatementViewModel, at indexPath: IndexPath) -> DetailsStatementCell {
        let cell: DetailsStatementCell = self.tableView.dequeueReusableCell(forIndexPath: indexPath)
        cell.avatarImageView.kf_setImage(with: details.ownerAvatar, loadImageOnFailure: R.image.defaultAvatar)
        cell.postImageView.kf_setImage(with: details.image, hideOnFailure: true)
        cell.titleLabel.text = details.title
        cell.votingView.rx_didTapAgree.bind(to: details.didTapAgree).addDisposableTo(cell.reusableDisposeBag)
        cell.votingView.rx_didTapDisagree.bind(to: details.didTapDisagree).addDisposableTo(cell.reusableDisposeBag)
        details.votingState.asObservable().bind(to: cell.votingView.rx_state).addDisposableTo(cell.reusableDisposeBag)
        cell.votingView.datasource = details
        cell.usernameLabel.text = details.ownername
        cell.dateLabel.text = details.postTime
        cell.explanation = details.explanation
        cell.sources = details.sources
        return cell
    }
    
    fileprivate func cell(for comment: CommentViewModel, at indexPath: IndexPath) -> CommentCell {
        let cell: CommentCell = self.tableView.dequeueReusableCell(forIndexPath: indexPath)
        cell.avatarImageView.kf_setImage(with: comment.authorAvatar, loadImageOnFailure: R.image.defaultAvatar)
        cell.commentLabel.text = comment.value
        cell.postTimeLabel.text = comment.timePast
        cell.usernameLabel.text = comment.authorUsername
        return cell
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        tabBarController?.tabBar.isHidden = true
        registerKeyboardHandling()
    }
    
    fileprivate func registerKeyboardHandling() {
        handleKeyboardPoping()
    }
    
    fileprivate func handleKeyboardPoping() {
        let keyboardHeight = keyboardHeightObservable()
        change(bottomConstraint, onChangeOf: keyboardHeight)
    }
    
    fileprivate func keyboardHeightObservable() -> Observable<CGFloat> {
        let keyboardHeightOnHiding =  NotificationCenter.default.rx.notification(NSNotification.Name.UIKeyboardWillHide)
            .takeUntil(rx_viewWillDisappear)
            .map { _ in return 0 as CGFloat }
        let keyboardHeightOnShow = NotificationCenter.default.rx.notification(NSNotification.Name.UIKeyboardWillShow)
            .takeUntil(rx_viewWillDisappear)
            .map { notification  in
                return notification.userInfo
                    .flatMap { ($0[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue }
                    .map { $0.size.height }
            }.filterNil()
        
        let keyboardHeight = Observable.of(keyboardHeightOnShow, keyboardHeightOnHiding).merge()
        
        return keyboardHeight
    }
    
    fileprivate func change(_ bottomConstraint: NSLayoutConstraint, onChangeOf keyboardHeight: Observable<CGFloat>) {
        keyboardHeight.subscribe(onNext: { [unowned self] height in
                bottomConstraint.constant = height
                self.view.layoutIfNeeded()
            }, onError: nil, onCompleted: nil, onDisposed: nil)
            .addDisposableTo(rx.disposeBag)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
        NotificationCenter.default.removeObserver(self)
    }
}

extension DetailsStatementVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return turnOffPossibilityToDeleteRowOnLeftSwipe()
    }
    
    fileprivate func turnOffPossibilityToDeleteRowOnLeftSwipe() -> UITableViewCellEditingStyle {
        return .none
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == DetailsStatementSections.details.position {
            return 350
        } else {
            return 50
        }
    }
}

extension DetailsStatementVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            return cell(for: viewModel.statementViewModel, at: indexPath)
        } else {
            return cell(for: viewModel.comments[indexPath.row], at: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return viewModel.comments.count
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
}

extension DetailsStatementVC: DetailsStatementViewModelDelegate {
    func didRefreshComments() {
        tableView.reloadSections(IndexSet(integer: 1), with: .fade)
    }
    
    func didAdd(comment: CommentViewModel, at index: Int) {
        let insertPosition = IndexPath(row: index, section: 1)
        tableView.insertItemsAtIndexPaths([insertPosition], animationStyle: .bottom)
        tableView.scrollToRow(at: insertPosition, at: .bottom, animated: true)
    }
}
