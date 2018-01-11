//
//  VotingView.swift
//  SwiftSampleCode
//
//  Created by Ada Chmielewska on 22.06.2016.
//  Copyright © 2016 All in Mobile. All rights reserved.
//

import UIKit

protocol VotingViewDelegate: class {
    func didTapAgree()
    func didTapDisagree()
}

protocol VotingViewDatasource: class {
    func textForLabelAbovePercentageBar(atState state:VotingView.State) -> String
    func disagreeAgreeVotesRatio() -> CGFloat
}

class VotingView: UIView {
    fileprivate let disagreeCircle = CAShapeLayer()
    fileprivate let agreeCircle = CAShapeLayer()
    fileprivate let percentageRect = CAShapeLayer()
    fileprivate let disagreeRect = CAShapeLayer()
    fileprivate let swipeableCircle = CAShapeLayer()
    fileprivate let smallerSwipeableCircle = CAShapeLayer()
    fileprivate let voteText = CATextLayer()
    fileprivate let circleLineWidth: CGFloat = 1
    fileprivate let swipeableCircleLineWidth: CGFloat = 1
    fileprivate let agreeIconSubLayer = CALayer()
    fileprivate let disagreeIconSubLayer = CALayer()
    fileprivate let lineColor = UIColor.projectGrayColor().cgColor
    fileprivate let swipeableCircleSize: CGFloat = 0.48
    fileprivate let insideSwipeableCircleSize: CGFloat = 0.125
    weak var delegate: VotingViewDelegate?
    weak var datasource: VotingViewDatasource?
    
    var stateOfVoting: VotingView.State {
        didSet {
            setup()
            if case VotingView.State.unvote = stateOfVoting {
                disagreeRect.removeFromSuperlayer()
                voteText.removeFromSuperlayer()
                showSwipeableCircle()
            } else {
                hideSwipeableCircle()
            }
        }
    }
    
    init(state: VotingView.State) {
        stateOfVoting = state
        super.init(frame: state.frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.stateOfVoting = .unvote
        super.init(coder: aDecoder)
        setup()
    }
    
    fileprivate func setup() {
        setupLine()
        setupStateCircles()
        setupSwipeableCircle()
        setupText()
    }
    
    fileprivate func hideSwipeableCircle() {
        swipeableCircle.isHidden = true
        smallerSwipeableCircle.isHidden = true
    }
    
    fileprivate func showSwipeableCircle() {
        swipeableCircle.isHidden = false
        smallerSwipeableCircle.isHidden = false
    }
    
    fileprivate func setupText() {
        voteText.alignmentMode = stateOfVoting.alignment
        voteText.font = UIFont.systemFont(ofSize: 10, weight: UIFontWeightLight)
        voteText.foregroundColor = UIColor.black.cgColor
        voteText.contentsScale = UIScreen.main.scale
        layer.addSublayer(voteText)
    }
    
    fileprivate func setupLine() {
        percentageRect.fillColor = stateOfVoting.voteLineColor
        percentageRect.strokeColor = stateOfVoting.voteLineColor
        percentageRect.lineWidth = stateOfVoting.percentageLineWidth
        layer.addSublayer(percentageRect)
        
        disagreeRect.fillColor = stateOfVoting.procentageLineColor
        disagreeRect.strokeColor = stateOfVoting.procentageLineColor
        disagreeRect.lineWidth = stateOfVoting.percentageLineWidth
        layer.addSublayer(disagreeRect)
    }
    
    fileprivate func setupStateCircles() {
        disagreeCircle.strokeColor = lineColor
        disagreeCircle.lineWidth = circleLineWidth
        disagreeCircle.fillColor = stateOfVoting.disagreeColor
        disagreeIconSubLayer.contents = stateOfVoting.disagreeIcon?.cgImage
        disagreeIconSubLayer.contentsGravity = kCAGravityCenter
        disagreeCircle.addSublayer(disagreeIconSubLayer)
        layer.addSublayer(disagreeCircle)
        
        agreeCircle.strokeColor = lineColor
        agreeCircle.lineWidth = circleLineWidth
        agreeCircle.fillColor = stateOfVoting.agreeColor
        agreeIconSubLayer.contents = stateOfVoting.agreeIcon?.cgImage
        agreeIconSubLayer.contentsGravity = kCAGravityCenter
        agreeCircle.addSublayer(agreeIconSubLayer)
        layer.addSublayer(agreeCircle)
    }
    
    fileprivate func setupSwipeableCircle() {
        swipeableCircle.strokeColor = stateOfVoting.swipeableColor
        swipeableCircle.lineWidth = swipeableCircleLineWidth
        swipeableCircle.fillColor = stateOfVoting.swipeableColor
        layer.addSublayer(swipeableCircle)
        
        smallerSwipeableCircle.strokeColor = UIColor.white.cgColor
        smallerSwipeableCircle.fillColor = UIColor.white.cgColor
        layer.addSublayer(smallerSwipeableCircle)
    }
    
    override func layoutSublayers(of layer: CALayer) {
        if layer == self.layer {
            updateMainSublayers()
        }
        super.layoutSublayers(of: layer)
    }
    
    fileprivate func updateMainSublayers() {
        configureText()
        configureDisagreeCircle()
        configureAgreeCircle()
        let centerOfDisagree = CGPoint(x: disagreeCircle.frame.midX - stateOfVoting.spaceUnvote, y: disagreeCircle.frame.midY - stateOfVoting.spaceVoted)
        let centerOfAgree = CGPoint(x: agreeCircle.frame.midX - stateOfVoting.spaceUnvote, y: centerOfDisagree.y - stateOfVoting.spaceVoted)
        configurePercentageLine(centerOfDisagree, endPoint: centerOfAgree, space: stateOfVoting.space)
        switch stateOfVoting {
        case .unvote: configureSwipeableCircle(swipeableCircleSize)
        case .agree, .disagree: configureVoteLine(centerOfDisagree, endPoint: centerOfAgree)
        }
    }
    
    fileprivate func configureText() {
        voteText.string = datasource?.textForLabelAbovePercentageBar(atState: stateOfVoting)
    }
    
    fileprivate func configureDisagreeCircle() {
        let disagreeFrame = CGRect(x: stateOfVoting.spaceUnvote, y:stateOfVoting.spaceVoted*0.5, width:bounds.height - stateOfVoting.spaceVoted*2, height:bounds.height - stateOfVoting.spaceVoted*2)
        let circleShape = UIBezierPath(ovalIn: circleShapeRect(CGPoint(x: circleLineWidth*0.5, y: circleLineWidth*0.5), multiper: 1))
        disagreeCircle.path = circleShape.cgPath
        disagreeCircle.frame = disagreeFrame
        disagreeIconSubLayer.frame = iconFrame()
        disagreeIconSubLayer.contentsGravity = kCAGravityResizeAspect
    }
    
    fileprivate func configureAgreeCircle() {
        let circleShape = UIBezierPath(ovalIn: circleShapeRect(CGPoint(x: circleLineWidth*0.5, y: circleLineWidth*0.5), multiper: 1))
        agreeCircle.path = circleShape.cgPath
        let startingPointOfAgreeCircle = CGPoint(x: bounds.width - bounds.height - stateOfVoting.spaceUnvote + stateOfVoting.spaceVoted, y: stateOfVoting.spaceVoted*0.5)
        let agreeFrame = CGRect(origin: startingPointOfAgreeCircle, size: CGSize(width: bounds.height, height: bounds.height))
        agreeCircle.frame = agreeFrame
        agreeIconSubLayer.frame = iconFrame()
        agreeIconSubLayer.contentsGravity = kCAGravityResizeAspect
    }
    
    fileprivate func iconFrame() -> CGRect {
        let centerOfDisagree = CGPoint(x: disagreeCircle.frame.midX, y: disagreeCircle.frame.midY)
        let point = CGPoint(x: centerOfDisagree.x - stateOfVoting.iconSize.width*0.5 - stateOfVoting.spaceUnvote + stateOfVoting.spaceVoted*0.5, y: centerOfDisagree.y - stateOfVoting.iconSize.height*0.5)
        return CGRect(origin: point, size: stateOfVoting.iconSize)
    }
    
    fileprivate func configureSwipeableCircle(_ multiplier: CGFloat) {
        let swipeableCircleShapeRect = circleShapeRect(CGPoint.zero, multiper: multiplier)
        let swipeableCircleShape = UIBezierPath(ovalIn: swipeableCircleShapeRect)
        swipeableCircle.path = swipeableCircleShape.cgPath
        let swipeableFram = frameForCircle(multiplier)
        swipeableCircle.frame = swipeableFram
        configureInsideOfSwipeableCircle(insideSwipeableCircleSize)
    }
    
    fileprivate func configureInsideOfSwipeableCircle(_ multiplier: CGFloat) {
        let smallerCircleShapeRect = circleShapeRect(CGPoint.zero, multiper: multiplier)
        let smallerCircleShape = UIBezierPath(ovalIn: smallerCircleShapeRect)
        smallerSwipeableCircle.path = smallerCircleShape.cgPath
        smallerSwipeableCircle.frame = frameForCircle(multiplier)
    }
    
    fileprivate func circleShapeRect(_ point: CGPoint, multiper: CGFloat) -> CGRect {
        return CGRect(origin: point, size: CGSize(width: (bounds.height-circleLineWidth - stateOfVoting.spaceVoted) * multiper, height: (bounds.height - circleLineWidth - stateOfVoting.spaceVoted) * multiper))
    }
    
    fileprivate func frameForCircle(_ multiplier: CGFloat) -> CGRect {
        let pointX = bounds.width * 0.5 - (bounds.height-circleLineWidth)*multiplier * 0.5
        let pointY = bounds.height * 0.5 - (bounds.height-circleLineWidth) * multiplier * 0.5
        return CGRect(origin: CGPoint(x: pointX, y: pointY), size: CGSize(width: (bounds.height-circleLineWidth - stateOfVoting.spaceVoted)*multiplier, height: (bounds.height-circleLineWidth - stateOfVoting.spaceVoted)*multiplier))
    }
    
    fileprivate func configurePercentageLine(_ beginPoint: CGPoint, endPoint: CGPoint, space: CGFloat) {
        let radiusOfCircles = bounds.height * 0.5
        var beginigOfLine = beginPoint
        beginigOfLine.x += (radiusOfCircles + space)
        var endOfLine = endPoint
        endOfLine.x -= (radiusOfCircles + space)
        let lineWidth = hypot(beginigOfLine.x - endOfLine.x, beginigOfLine.y - endOfLine.y)
        drawnPercentageLine(lineWidth, beginigOfLine: beginigOfLine)
        drawnText(lineWidth, beginigOfLine: beginigOfLine)
    }
    
    fileprivate func drawnText(_ lineWidth: CGFloat, beginigOfLine: CGPoint) {
        let percentageSize = CGSize(width: lineWidth, height: 15)
        let lineFrame = CGRect(origin: beginigOfLine, size: percentageSize)
        voteText.frame = lineFrame
        voteText.position = CGPoint(x: bounds.midX, y: bounds.midY/2)
        voteText.fontSize = 10
    }
    
    fileprivate func drawnPercentageLine(_ lineWidth: CGFloat, beginigOfLine: CGPoint) {
        let percentageSize = CGSize(width: lineWidth, height: stateOfVoting.percentageLineWidth)
        let lineFrame = CGRect(origin: beginigOfLine, size: percentageSize)
        percentageRect.path = UIBezierPath(rect: CGRect(origin: CGPoint.zero, size: percentageSize)).cgPath
        percentageRect.frame = lineFrame
        percentageRect.position = CGPoint(x: bounds.midX, y: bounds.midY)
    }
    
    fileprivate func configureVoteLine(_ beginPoint: CGPoint, endPoint: CGPoint) {
        let disagreeAgreeRatio = self.datasource?.disagreeAgreeVotesRatio() ?? 0
        
        let radiusOfCircles = bounds.height/2
        var beginigOfLine = beginPoint
        beginigOfLine.x += (radiusOfCircles + stateOfVoting.space)
        var endOfLine = endPoint
        endOfLine.x -= (radiusOfCircles + stateOfVoting.space)
        let lineWidth = hypot(beginigOfLine.x - endOfLine.x, beginigOfLine.y - endOfLine.y) * disagreeAgreeRatio
        drawnVoteLine(lineWidth, beginigOfLine: beginigOfLine)
    }
    
    fileprivate func drawnVoteLine(_ lineWidth: CGFloat, beginigOfLine: CGPoint) {
        let percentageSize = CGSize(width: lineWidth, height: stateOfVoting.percentageLineWidth)
        let lineFrame = CGRect(origin: beginigOfLine, size: percentageSize)
        disagreeRect.path = UIBezierPath(rect: CGRect(origin: CGPoint.zero, size: percentageSize)).cgPath
        disagreeRect.frame = lineFrame
        disagreeRect.position.y = bounds.midY
        
        preventDisplayingDisagreeRectBordersIfNeeded()
    }
    
    fileprivate func preventDisplayingDisagreeRectBordersIfNeeded() {
        disagreeRect.isHidden = ( disagreeRect.frame.size.width == 0 )
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let point = touches.first?.location(in: self) else { return }
        
        if agreeCircle.frame.contains(point) {
            delegate?.didTapAgree()
        }
        
        if disagreeCircle.frame.contains(point) {
            delegate?.didTapDisagree()
        }
    }
}
