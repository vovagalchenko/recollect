//
//  RepeatView.swift
//  recollect
//
//  Created by Vova Galchenko on 1/7/15.
//  Copyright (c) 2015 Vova Galchenko. All rights reserved.
//

import UIKit

class RepeatIconView: ButtonBackground {
    
    override func draw(_ rect: CGRect) {
        let ctx = UIGraphicsGetCurrentContext()
        
        let boundingBoxDimension = min(bounds.height, bounds.width)
        let arrowShaftThickness = boundingBoxDimension/6.0
        let arrowThickness = (arrowShaftThickness*2.0)
        
        ctx?.translateBy(x: bounds.width, y: 0.0)
        ctx?.scaleBy(x: -1.0, y: 1.0)
        
        let arcEndingAngle = 0.8 * CGFloat.pi * 2.0
        ctx?.addArc(
            center: CGPoint(x: bounds.midX, y: bounds.midY),
            radius: boundingBoxDimension/2.0 - arrowShaftThickness*0.5 - ((arrowThickness - arrowShaftThickness)*0.5),
            startAngle: 0,
            endAngle: arcEndingAngle,
            clockwise: false
        )
        ctx?.setLineWidth(arrowShaftThickness)
        baseColor.setStroke()
        ctx?.strokePath()
        
        ctx?.translateBy(x: bounds.midX, y: bounds.midY)
        ctx?.rotate(by: arcEndingAngle)
        ctx?.translateBy(x: -bounds.midX, y: -bounds.midY)

        ctx?.move(to: CGPoint(x: bounds.size.width - arrowThickness, y: bounds.midY))
        ctx?.addLine(to: CGPoint(x: bounds.size.width, y: bounds.midY))
        ctx?.addLine(to:
            CGPoint(x: bounds.size.width - arrowThickness*0.5, y: bounds.midY + (sqrt(3.0)/2.0)*arrowThickness)
        )
        ctx?.closePath()
        baseColor.setFill()
        ctx?.setLineWidth(0.5)
        ctx?.drawPath(using: CGPathDrawingMode.fillStroke)
    }
    
    override var intrinsicContentSize : CGSize {
        return CGSize(width: 40, height: 40)
    }
}
