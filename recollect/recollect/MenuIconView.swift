//
//  MenuView.swift
//  recollect
//
//  Created by Vova Galchenko on 1/8/15.
//  Copyright (c) 2015 Vova Galchenko. All rights reserved.
//

import UIKit

class MenuIconView: ButtonBackground {
    override func draw(_ rect: CGRect) {
        let ctx = UIGraphicsGetCurrentContext()
        
        let boundingBoxDimension = min(bounds.height, bounds.width)
        let lineThickness = boundingBoxDimension/6.0
        let numLines = 3
        
        ctx?.setLineWidth(lineThickness)
        ctx?.setLineCap(CGLineCap.round)
        baseColor.setStroke()
        
        for i in 0..<numLines {
            let y = (bounds.height/CGFloat(numLines + 1))*CGFloat(i + 1)
            ctx?.move(to: CGPoint(x: lineThickness/2.0, y: y))
            ctx?.addLine(to: CGPoint(x: lineThickness/2.0, y: y))
            ctx?.move(to: CGPoint(x: lineThickness*2.0, y: y))
            ctx?.addLine(to: CGPoint(x: bounds.width - (lineThickness/2.0), y: y))
        }
        ctx?.strokePath()
    }
    
    override var intrinsicContentSize : CGSize {
        return CGSize(width: 40, height: 40)
    }
}
