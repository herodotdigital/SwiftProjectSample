//
//  AimHomeTabNavigatorView.swift
//  SwiftSampleCode
//
//  Created by dev on 03.06.2016.
//  Copyright © 2016 All in Mobile. All rights reserved.
//

import UIKit
import SnapKit
import RxCocoa
import RxSwift

class AimHomeTabNavigatorView: UIControl {

    fileprivate var labels = [UILabel]()
    fileprivate var tickerView = UIView()
    let tickerHeight: CGFloat = 4
    var selectedLabelFont: UIFont = UIFont.systemFont(ofSize: 18, weight: UIFontWeightMedium)
    var unselectedLabelFont: UIFont = UIFont.systemFont(ofSize: 18, weight: UIFontWeightLight)
    
    var tickerHidden: Bool {
        get {
            return tickerView.isHidden
        }
        
        set {
            tickerView.isHidden = newValue
        }
    }
    
    var padding: CGFloat = 0 {
        didSet {
            setupLabels()
        }
    }
    var tickerColor: UIColor = UIColor.projectBlackColor() {
        didSet {
            displayNewSelectedIndex()
        }
    }

    var items: [String] = [] {
        didSet {
            setupLabels()
        }
    }

    var selectedIndex: Int = 0 {
        didSet {
            displayNewSelectedIndex()
            self.sendActions(for: .valueChanged)
        }
    }
    
    init(frame: CGRect, fontSize: CGFloat) {
        super.init(frame: frame)
        selectedLabelFont = UIFont.systemFont(ofSize: fontSize, weight: UIFontWeightMedium)
        unselectedLabelFont = UIFont.systemFont(ofSize: fontSize, weight: UIFontWeightLight)
        setupView()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    fileprivate func setupView() {
        backgroundColor = UIColor.clear
        insertSubview(tickerView, at: 0)
    }

    fileprivate func setupLabels() {

        removeLabelsFromSuperView()

        for text in items {
            let label = createLabel(text)
            self.addSubview(label)
            labels.append(label)
        }

        addIndividualItemConstraints(labels, mainView: self, padding: padding)
    }

    fileprivate func removeLabelsFromSuperView() {
        for label in labels {
            label.removeFromSuperview()
        }
        labels.removeAll(keepingCapacity: true)
    }

    fileprivate func createLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.backgroundColor = UIColor.clear
        label.textAlignment = .center
        label.textColor = UIColor.projectWhiteThreeColor()
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        var selectFrame = self.bounds
        let newWidth = selectFrame.width / CGFloat(items.count)
        selectFrame.size.width = newWidth
        selectFrame.size.height = tickerHeight

        displayNewSelectedIndex()
    }

    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let location = touch.location(in: self)
        for (index, item) in labels.enumerated() {
            if item.frame.contains(location) {
                selectedIndex = index
            }
        }

        return false
    }

    fileprivate func displayNewSelectedIndex() {

        guard selectedIndex < labels.count
            else {return}

            let label = labels[selectedIndex]
            setSelectedFont(selectedIndex)

            UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 1, options: [], animations: {
                self.tickerView.frame = label.frame
                self.tickerView.frame.size.height = self.tickerHeight
                self.tickerView.frame.origin.y = label.frame.size.height - self.tickerHeight
                self.tickerView.backgroundColor = self.tickerColor
            }, completion: nil)
    }

    fileprivate func addIndividualItemConstraints(_ items: [UIView], mainView: UIView, padding: CGFloat) {

        let tabWidth = (UIScreen.main.bounds.width - padding * 2) / CGFloat(items.count)
        if tabWidth == 0 {
            return
        }
        var previousView: UIView? = nil
        for view in items {
            view.snp_makeConstraints { make in
                make.top.equalTo(mainView)
                make.bottom.equalTo(mainView)
                make.width.equalTo(tabWidth)
                if let previousView = previousView {
                    make.left.equalTo(previousView.snp_right)
                } else {
                    make.left.equalTo(mainView).offset(padding)
                }
            }
            previousView = view
        }
        previousView?.snp_makeConstraints { make in
            make.right.equalTo(mainView).offset(-padding)
        }
    }

    fileprivate func setSelectedFont(_ index: Int) {
        for item in labels {
            item.font = unselectedLabelFont
        }
        if index < labels.count {
            labels[selectedIndex].font = selectedLabelFont
        }
    }
}

extension AimHomeTabNavigatorView {
    var rx_selectedIndex: ControlProperty<Int> {
        return AimHomeTabNavigatorView.valuePublic(
            self,
            getter: { tabNavigator in
                tabNavigator.selectedIndex ?? 0
            }, setter: { tabNavigator, value in
                if tabNavigator.selectedIndex != value {
                    tabNavigator.selectedIndex = value
                }
            }
        )
    }
}
