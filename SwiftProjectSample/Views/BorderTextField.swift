//
//  BorderTextField.swift
//  SwiftSampleCode
//
//  Created by Ada Chmielewska on 08.06.2016.
//  Copyright © 2016 All in Mobile. All rights reserved.
//

import UIKit

class BorderTextField: UITextField {

    var borderColor: UIColor = UIColor.projectPinkishGreyColor()
    var borderWidth: CGFloat = 1.0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSelectors()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addSelectors()
    }
    
    fileprivate func addSelectors() {
        addTarget(self, action: #selector(BorderTextField.redBottomBorder), for: .editingChanged)
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        let startPoint = CGPoint(x:0, y:rect.size.height - borderWidth)
        let endPoint = CGPoint(x: rect.size.width, y: rect.size.height - borderWidth)
        drawLineFromPoint(startPoint, to: endPoint, width: borderWidth, color: borderColor)
    }
    
    func drawLineFromPoint(_ from: CGPoint, to: CGPoint, width: CGFloat, color: UIColor) {
        let context: CGContext = (UIGraphicsGetCurrentContext())!
        context.setLineWidth(width)
        context.setStrokeColor(color.cgColor)
        context.move(to: CGPoint(x: from.x, y: from.y))
        context.addLine(to: CGPoint(x: to.x, y: to.y))
        context.strokePath()
    }
    
    func grayBottomBorder() {
        borderColor = UIColor.projectPinkishGreyColor()
        borderWidth = 1.0
        setNeedsDisplay()
    }
    
    func redBottomBorder() {
        borderColor = UIColor.projectTomatoColor()
        borderWidth = 2.0
        setNeedsDisplay()
    }
}
