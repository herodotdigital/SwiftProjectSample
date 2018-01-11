//
//  AddPollVC.swift
//  SwiftSampleCode
//
//  Created by Ada Chmielewska on 13.07.2016.
//  Copyright © 2016 All in Mobile. All rights reserved.
//

import UIKit
import Cartography
import RxSwift
import RxCocoa

class AddPollVC: AddContentVC {
    
    @IBOutlet weak var contentViewForAnswers: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var answerLabel: UILabel!
    fileprivate var answerConstraintsToUpdate = ConstraintGroup()
    fileprivate var disposeBagForLastAnswer = DisposeBag()
    fileprivate var answerViews: [AnswerView] = []
    fileprivate var placeholdersForAnswer = [LocalizedString("First answer"), LocalizedString("Second answer"), LocalizedString("Third answer"), LocalizedString("Fourth answer"), LocalizedString("Fifth answer")]
    fileprivate let topMarginToAnswerView: CGFloat = 0
    fileprivate let viewModel: AddPollViewModel
    
    init(withViewModel viewModel: AddPollViewModel) {
        self.viewModel = viewModel
        super.init(withViewModel: viewModel, nib: R.nib.addPollVC)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTopBar(title: LocalizedString("Question"), titleColor: UIColor.white)
        addFirstAnswer()
    }
    
    fileprivate func addFirstAnswer() {
        let newView = newAnswerView()
        addConstraintsToAnswerView(newView, belowTheView: answerLabel, parentView: contentViewForAnswers, topMargin: topMarginToAnswerView)
        defineWhenNextAnswerViewShouldBeAdded(newView)
    }
    
    fileprivate func newAnswerView() -> AnswerView {
        if let answerView = AnswerView.loadForNib() {
            contentViewForAnswers.addSubview(answerView)
            answerView.answerTitle.scrollView = scrollView
            addPlaceholder(answerView.answerTitle)
            answerViews.append(answerView)
            bindAnswerViewWithViewModel(answerView)
            return answerView
        }
        return AnswerView()
    }
    
    func bindAnswerViewWithViewModel(_ answerView: AnswerView) {
        if let index = answerViews.index(of: answerView), index < viewModel.maximumAnswers - 1 {
            answerView.answerTitle.rx.text.orEmpty.bind(to: viewModel.answers[index]).addDisposableTo(rx.disposeBag)
            viewModel.answersCount[index].drive(answerView.answerCounter.rx.text).addDisposableTo(rx.disposeBag)
        }
    }
    
    fileprivate func addConstraintsToAnswerView(_ view: UIView, belowTheView: UIView, parentView: UIView, topMargin: CGFloat) {
        
        addConstraintToPut(view: view, belowTheView: belowTheView, parentView: parentView, topMargin: topMargin)
        answerConstraintsToUpdate = constrain(view, parentView, replace:answerConstraintsToUpdate) { viewToPut, superview in
        viewToPut.bottom == superview.bottom
        }
        
        view.layoutIfNeeded()
    }
    
    fileprivate func addPlaceholder(_ textView: ResizeableTextView) {
        if answerViews.count < placeholdersForAnswer.count {
            textView.placeholder = placeholdersForAnswer[answerViews.count]
        }
    }
    
    fileprivate func defineWhenNextAnswerViewShouldBeAdded(_ newestAnswerView: AnswerView) {
        disposePreviousAnswerViewObservable()
        if answerViews.count == 1 {
            addNewAnswerView()
            return
        }
        
        if answerViews.count < viewModel.maximumAnswers {
        newestAnswerView.answerTitle.rx.text.orEmpty
            .filter { text in
                return text.hasMoreCharactersThan(0)
            }
            .subscribe(onNext: { [unowned self] _ in
                self.addNewAnswerView()
            }, onError: nil, onCompleted: nil, onDisposed: nil)
            .addDisposableTo(disposeBagForLastAnswer)
        }
    }
    
    fileprivate func disposePreviousAnswerViewObservable() {
        disposeBagForLastAnswer = DisposeBag()
    }
    
    fileprivate func addNewAnswerView() {
        if let lastView = answerViews.last {
            let newView = newAnswerView()
            addConstraintsToAnswerView(newView, belowTheView: lastView, parentView: contentViewForAnswers, topMargin: topMarginToAnswerView)
            defineWhenNextAnswerViewShouldBeAdded(newView)
        }
    }
}
