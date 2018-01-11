//
//  PostsListVC.swift
//  SwiftSampleCode
//
//  Created by Adam Borek on 13.06.2016.
//  Copyright © 2016 All in Mobile. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import NSObject_Rx

import Kingfisher

struct PostsSection {
    var items: [Item]
}

extension PostsSection: SectionModelType {
    typealias Item = PostViewModel
    
    init(original: PostsSection, items: [Item]) {
        self = original
        self.items = items
    }
}

class PostsListVC: AimViewController {
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.register(R.nib.statementCell)
        }
    }
    weak var refreshControl: UIRefreshControl?
    
    let viewModel: PostsListViewModel
    let datasource: RxTableViewSectionedReloadDataSource<PostsSection>
    
    init(withViewModel viewModel: PostsListViewModel) {
        self.viewModel = viewModel
        datasource = RxTableViewSectionedReloadDataSource<PostsSection>()
        super.init(nibResource: R.nib.postsListVC)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        configureCells()
        defineWhenStatementsShouldBeUpdated()
        defineOnCellClickAction()
    }
    
    fileprivate func configureTableView() {
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 300
        let refreshControl = UIRefreshControl()
        tableView.addSubview(refreshControl)
        self.refreshControl = refreshControl
        tableView.rx.setDelegate(self)
            .addDisposableTo(rx.disposeBag)
    }
    
    fileprivate func configureCells() {
        datasource.configureCell = { [weak self] (dataSource, tableView, idxPath, item) in
            switch item {
            case let statement as StatementViewModel:
                let statementCell: StatementCell = tableView.dequeueReusableCell(forIndexPath: idxPath)
                self?.bind(statementCell, with: statement)
                return statementCell
            default:
                assert(false, "Should not happen. All cells need to be handled")
                return UITableViewCell()
            }
        }
    }
    
    fileprivate func bind(_ cell: StatementCell, with viewModel: StatementViewModel) {
        bindCommonFields(in: cell, with: viewModel)
        viewModel.votingState.asObservable().bind(to: cell.voteView.rx_state).addDisposableTo(cell.reusableDisposeBag)
        cell.voteView.rx_didTapAgree.bind(to: viewModel.didTapAgree).addDisposableTo(cell.reusableDisposeBag)
        cell.voteView.rx_didTapDisagree.bind(to: viewModel.didTapDisagree).addDisposableTo(cell.reusableDisposeBag)
        cell.voteView.datasource = viewModel
    }
    
    fileprivate func bindCommonFields(in cell: PostCell, with viewModel: PostViewModel) {
        cell.titleLabel.text = viewModel.title
        cell.postImageView.image = nil
        cell.ownernameLabel.text = viewModel.ownername
        cell.avatarImageView.kf_setImage(with: viewModel.ownerAvatar, loadImageOnFailure: R.image.defaultAvatar)
        cell.postImageView?.kf_setImage(with: viewModel.image, hideOnFailure: true)
        cell.postTimeLabel.text = viewModel.postTime
    }
    
    fileprivate func defineWhenStatementsShouldBeUpdated() {
        let onRefreshDrag =  refreshControl?.rx.controlEvent(.valueChanged).asDriver()
            .map { [unowned self] in
                return self.refreshControl?.isRefreshing ?? false
            }.filter { refreshing in
                return refreshing
        }
        onRefreshDrag?
            .updateAlsoAtViewDidLoad()
            .flatMap { _ in
                return  self.posts
            }.do(onNext: { [unowned self] _ in
                self.refreshControl?.endRefreshing()
            }, onCompleted: nil, onSubscribe: nil, onSubscribed: nil, onDispose: nil)
            .drive(tableView.rx.items(dataSource: datasource))
            .addDisposableTo(rx.disposeBag)
    }
    
    fileprivate func defineOnCellClickAction() {
        tableView.rx.itemSelected.subscribe { [unowned self] indexPath in
            guard let index = indexPath.element else {
                return
            }
            switch self.datasource[index] {
            case let statement as StatementViewModel:
                let detailVC = Assembly.Controllers.detailsStatementVC(withViewModel: statement)
                self.navigationController?.show(detailVC, sender: self)
            default:
                break
            }
            
            }.addDisposableTo(rx.disposeBag)
    }
    
    var posts: Driver<[PostsSection]> {
        return  viewModel.posts()
            .map { viewModels in
                return [PostsSection(items: viewModels)]
        }
    }
}

extension PostsListVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .none
    }
}

fileprivate extension SharedSequenceConvertibleType where SharingStrategy == DriverSharingStrategy, E == Bool {
    func updateAlsoAtViewDidLoad() -> Driver<Self.E> {
        return startWith(true)
    }
}
