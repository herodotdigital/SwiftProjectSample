//
//  AddContentVC.swift
//  SwiftSampleCode
//
//  Created by Ada Chmielewska on 17.07.2016.
//  Copyright © 2016 All in Mobile. All rights reserved.
//

import UIKit
import Cartography
import RxSwift
import RxCocoa
import Rswift

class AddContentVC: AimViewController {
    
    @IBOutlet weak var imageButton: UIButton!
    @IBOutlet weak var addPhotoIcon: UIImageView!
    @IBOutlet weak var changePhotoIcon: UIImageView!
    @IBOutlet weak var changePhotoView: UIView!
    @IBOutlet weak var photoConstraint: NSLayoutConstraint!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var sourcesLabel: UILabel!
    @IBOutlet weak var titleTextView: UITextView!
    @IBOutlet weak var titleCountLabel: UILabel!
    @IBOutlet weak var explanationTextView: ResizeableTextView!
    @IBOutlet weak var ownernameLabel: UILabel!

    fileprivate let viewModel: AddContentViewModel
    
    fileprivate var constraintsToUpdate = ConstraintGroup()
    fileprivate let photoHeight: CGFloat = 170
    fileprivate let imagePicker = ImagePicker()
    fileprivate var sourcesFields: [UITextField] = []
    fileprivate var disposeBagForLastSourceField = DisposeBag()
    fileprivate let bottomMarginToSourceField: CGFloat = 40
    fileprivate let topMarginToSourceField: CGFloat = 20

    init(withViewModel viewModel: AddContentViewModel, nib: NibResourceType?) {
        self.viewModel = viewModel
        super.init(nibResource: nib)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureSubviews()
        bindWithViewModel()
    }
    
    func addConstraintToPut(view viewToPut: UIView, belowTheView viewAtTop: UIView, parentView: UIView, topMargin: CGFloat) {
        constrain(viewToPut, viewAtTop) { viewToPut, viewAtTop in
            viewToPut.left == viewAtTop.left
            viewToPut.right == viewAtTop.right
            viewToPut.top == viewAtTop.bottom + topMargin
        }
    }
    
    func currentText(_ text: String, hasMoreCharactersThan moreThan: Int) -> Bool {
        return text.count > moreThan
    }
    
    fileprivate func configureSubviews() {
        imageButton.imageView?.contentMode = .scaleAspectFill
        configureTopCloseAndSendButton()
        configureFirstSourceInput()
    }

    fileprivate func configureTopCloseAndSendButton() {
        let sendButton = UIBarButtonItem(image: R.image.sendinactive.image, style: .plain, target: nil, action: nil)
        sendButton.rx.tap.bind(to: viewModel.sendTaps).addDisposableTo(rx.disposeBag)
        viewModel.possibleToCreatePost.asObservable().bind(to: sendButton.rx.isEnabled).addDisposableTo(rx.disposeBag)
        
        let closeButton = UIBarButtonItem(image: R.image.cancelNav.image, style: .plain, target: nil, action: nil)
        closeButton.rx.tap
            .subscribe(onNext: { [unowned self] in
                self.dismiss(animated: true, completion: nil)
            }, onError: nil, onCompleted: nil, onDisposed: nil)
            .addDisposableTo(rx.disposeBag)
        
        navigationItem.setLeftBarButton(closeButton, animated: true)
        navigationItem.setRightBarButton(sendButton, animated: true)
    }
    
    fileprivate func configureFirstSourceInput() {
        let sourceTextField: BorderTextField = BorderTextField()
        configureSourceTextField(sourceTextField)
        contentView.addSubview(sourceTextField)
        sourcesFields.append(sourceTextField)
        addConstraintsToNewView(sourceTextField, belowTheView: sourcesLabel, parentView: contentView, topMargin: topMarginToSourceField)
        defineWhenNextSourceFieldShouldBeAdded(sourceTextField)
    }
    
    fileprivate func addConstraintsToNewView(_ viewToPut: UIView, belowTheView viewAtTop: UIView, parentView: UIView, topMargin: CGFloat) {
    
        addConstraintToPut(view: viewToPut, belowTheView: viewAtTop, parentView: parentView, topMargin: topMargin)
        constraintsToUpdate = constrain(viewToPut, parentView, replace:constraintsToUpdate) { viewToPut, superview in
            viewToPut.bottom == superview.bottom - bottomMarginToSourceField
        }
        
        view.layoutIfNeeded()
    }
    
    fileprivate func defineWhenNextSourceFieldShouldBeAdded(_ newestSourceTextField: UITextField) {
        disposePreviousSourceFieldObservable()
        newestSourceTextField.rx.text
            .filter { text in
                return (text ?? "").hasMoreCharactersThan(0)
            }.subscribe(onNext: { [unowned self] _ in
                self.addNewSourceField()
            }, onError: nil, onCompleted: nil, onDisposed: nil)
            .addDisposableTo(disposeBagForLastSourceField)
    }
    
    fileprivate func disposePreviousSourceFieldObservable() {
        disposeBagForLastSourceField = DisposeBag()
    }
    
    fileprivate func addNewSourceField() {
        if let lastTextField = sourcesFields.last {
            let nextSourceTextField = BorderTextField(frame: lastTextField.frame)
            sourcesFields.append(nextSourceTextField)
            contentView.addSubview(nextSourceTextField)
            addConstraintsToNewView(nextSourceTextField, belowTheView: lastTextField, parentView: contentView, topMargin: topMarginToSourceField)
            configureSourceTextField(nextSourceTextField)
            defineWhenNextSourceFieldShouldBeAdded(nextSourceTextField)
        }
    }
    
    func bindWithViewModel() {
        titleTextView.rx.text.orEmpty.bind(to: viewModel.title).addDisposableTo(rx.disposeBag)
        viewModel.titleCount?.asObservable().bind(to: titleCountLabel.rx.text).addDisposableTo(rx.disposeBag)
        explanationTextView.rx.text.orEmpty.bind(to: viewModel.explanation).addDisposableTo(rx.disposeBag)
        viewModel.postOwnername.asObservable().bind(to: ownernameLabel.rx.text).addDisposableTo(rx.disposeBag)
        viewModel.image.asObservable()
            .subscribe(onNext: { [unowned self] image in
                self.imageButton.setImage(image, for: .normal)
                if image != nil {
                    self.showChangePhoto()
                } else {
                    self.hideChangePhoto()
                }
            }, onError: nil, onCompleted: nil, onDisposed: nil)
            .addDisposableTo(rx.disposeBag)
        
        handleDataState()
    }
    
    fileprivate func handleDataState() {
        viewModel.loadingState.asObservable().subscribe(onNext: { [unowned self] dataState in
            switch dataState {
                case .loading:
                    self.showWaitView()
                case .failed(let errorMessage):
                    self.hideWaitView()
                    self.showErrorMessage(errorMessage)
                case .loaded(_):
                    self.dismissSelf()
                default:()
            }
        }, onError: nil, onCompleted: nil, onDisposed: nil).addDisposableTo(rx.disposeBag)
    }
    
    fileprivate func showWaitView() {
        navigationController?.show(WaitingVC(), sender: self)
    }
    
    fileprivate func hideWaitView() {
        navigationController?.popViewController(animated: true)
    }
    
    fileprivate func dismissSelf() {
        dismiss(animated: true, completion: nil)
    }
    
    fileprivate func showErrorMessage(_ message: String?) {
        guard let message = message else {
            return
        }
        
        let alert = UIAlertController.init(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: LocalizedString("OK"), style: .default) { [unowned alert] _ in
            alert.dismiss(animated: true, completion: nil)
            })
        self.navigationController?.present(alert, animated: true, completion: nil)
    }
    
    fileprivate func showChangePhoto() {
        changePhotoIcon.isHidden = false
        changePhotoView.isHidden = false
        addPhotoIcon.isHidden = true
    }
    
    fileprivate func hideChangePhoto() {
        changePhotoIcon.isHidden = true
        changePhotoView.isHidden = true
        addPhotoIcon.isHidden = false
    }
    
    @IBAction func imagePickerClicked(_ sender: UIButton) {
        imagePicker.configureImagePicker(self)
        imagePicker.delegate = self
    }
    
    fileprivate func configureSourceTextField(_ textField: UITextField) {
        textField.placeholder = LocalizedString("Website, book, article, etc.")
        textField.font =  UIFont.systemFont(ofSize: 14, weight: UIFontWeightLight)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
}

extension AddContentVC: ImagePickerDelegate {
    
    func didFinishWithImage(_ image: UIImage?) {
        if let image = image {
            viewModel.image.value = image
        }
        
        photoConstraint?.constant = photoHeight
        view.layoutIfNeeded()
    }
}

extension AddContentVC: AddContentViewModelDelegate {
    func sourcesForThePost() -> [String] {
        return sourcesFields
            .map { texField in
                return texField.text ?? ""
        }
    }
}

extension String {
    func hasMoreCharactersThan(_ moreThan: Int) -> Bool {
        return self.count > moreThan
    }
}

