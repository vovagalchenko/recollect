//
//  BorderView.swift
//  recollect
//
//  Created by Vova Galchenko on 1/11/15.
//  Copyright (c) 2015 Vova Galchenko. All rights reserved.
//

import UIKit

class BorderView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        opaque = false
        clearsContextBeforeDrawing = true
        setTranslatesAutoresizingMaskIntoConstraints(false)
    }
    
    convenience override init() {
        self.init(frame: CGRectZero)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented. We don't expect it to ever get called because we're not using nibs.")
    }
    
    override func drawRect(rect: CGRect) {
        let ctx = UIGraphicsGetCurrentContext()
        
        let (rectangePoints, lineThickness) = pixelPerfectCoordinates(
            thicknessInPixels: 1,
            points: CGPoint(x: 0, y: 0),
                    CGPoint(x: bounds.width, y: 0),
                    CGPoint(x: bounds.width, y: bounds.height),
                    CGPoint(x: 0, y: bounds.height)
        )
        
        let roundedRectPath = UIBezierPath(
            roundedRect: CGRect(
                origin: rectangePoints[0],
                size: CGSize(width: rectangePoints[1].x - rectangePoints[0].x,
                            height: rectangePoints[2].y - rectangePoints[1].y)),
            cornerRadius: 5.0)
        
        CGContextAddPath(ctx, roundedRectPath.CGPath)
        CGContextSetLineDash(ctx, 0, [1.0, 1.0], 2)
        CGContextSetLineWidth(ctx, lineThickness)
        DesignLanguage.AccentTextColor.setStroke()
        CGContextStrokePath(ctx)
    }
    
}