//
//  GradientView.swift
//  recollect
//
//  Created by Vova Galchenko on 1/3/15.
//  Copyright (c) 2015 Vova Galchenko. All rights reserved.
//

import UIKit

class GradientView: UIView {
    
    let gradient: CGGradientRef
    
    override init(frame: CGRect) {
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        gradient = CGGradientCreateWithColorComponents(colorSpace, [
            0.0, 0.0, 0.0, 0.0,
            0.0, 0.0, 0.0, 0.2
        ], [0.0, 1.0], 2)!
        
        super.init(frame: frame)
        opaque = false
        clearsContextBeforeDrawing = true
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented. We don't expect it to ever get called because we're not using nibs.")
    }
    
    override func drawRect(rect: CGRect) {
        let ctx = UIGraphicsGetCurrentContext()
        CGContextDrawLinearGradient(ctx, gradient, CGPoint(x: 0, y: 0), CGPoint(x: 0, y: bounds.size.height), [])
        
        CGContextMoveToPoint(ctx, bounds.size.width, 0.0)
        CGContextAddLineToPoint(ctx, bounds.size.width, bounds.size.height)
        
        CGContextSetLineWidth(ctx, 2.0)
        DesignLanguage.ShadowColor.setStroke()
        CGContextStrokePath(ctx)
    }
}