//
//  MenuView.swift
//  recollect
//
//  Created by Vova Galchenko on 1/8/15.
//  Copyright (c) 2015 Vova Galchenko. All rights reserved.
//

import UIKit

class MenuIconView: ButtonBackground {
    override func drawRect(rect: CGRect) {
        let ctx = UIGraphicsGetCurrentContext()
        
        let boundingBoxDimension = min(bounds.height, bounds.width)
        let lineThickness = boundingBoxDimension/6.0
        let numLines = 3
        
        CGContextSetLineWidth(ctx, lineThickness)
        CGContextSetLineCap(ctx, kCGLineCapRound)
        baseColor.setStroke()
        
        for i in 0..<numLines {
            let y = (bounds.height/CGFloat(numLines + 1))*CGFloat(i + 1)
            CGContextMoveToPoint(ctx, lineThickness/2.0, y)
            CGContextAddLineToPoint(ctx, lineThickness/2.0, y)
            CGContextMoveToPoint(ctx, lineThickness*2.0, y)
            CGContextAddLineToPoint(ctx, bounds.width - (lineThickness/2.0), y)
        }
        CGContextStrokePath(ctx)
    }
    
    override func intrinsicContentSize() -> CGSize {
        return CGSize(width: 40, height: 40)
    }
}
