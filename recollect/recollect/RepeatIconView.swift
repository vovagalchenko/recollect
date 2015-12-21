//
//  RepeatView.swift
//  recollect
//
//  Created by Vova Galchenko on 1/7/15.
//  Copyright (c) 2015 Vova Galchenko. All rights reserved.
//

import UIKit

class RepeatIconView: ButtonBackground {
    
    override func drawRect(rect: CGRect) {
        let ctx = UIGraphicsGetCurrentContext()
        
        let boundingBoxDimension = min(bounds.height, bounds.width)
        let arrowShaftThickness = boundingBoxDimension/6.0
        let arrowThickness = (arrowShaftThickness*2.0)
        
        CGContextTranslateCTM(ctx, bounds.width, 0.0)
        CGContextScaleCTM(ctx, -1.0, 1.0)
        
        let arcEndingAngle = CGFloat(0.8*(M_PI*2.0))
        CGContextAddArc(
            ctx,
            CGRectGetMidX(bounds),
            CGRectGetMidY(bounds),
            boundingBoxDimension/2.0 - arrowShaftThickness*0.5 - ((arrowThickness - arrowShaftThickness)*0.5),
            0,
            arcEndingAngle,
            0)
        CGContextSetLineWidth(ctx, arrowShaftThickness)
        baseColor.setStroke()
        CGContextStrokePath(ctx)
        
        CGContextTranslateCTM(ctx, CGRectGetMidX(bounds), CGRectGetMidY(bounds))
        CGContextRotateCTM(ctx, arcEndingAngle)
        CGContextTranslateCTM(ctx, -CGRectGetMidX(bounds), -CGRectGetMidY(bounds))

        CGContextMoveToPoint(ctx, bounds.size.width - arrowThickness, CGRectGetMidY(bounds))
        CGContextAddLineToPoint(ctx, bounds.size.width, CGRectGetMidY(bounds))
        CGContextAddLineToPoint(ctx, bounds.size.width - arrowThickness*0.5, CGRectGetMidY(bounds) + (sqrt(3.0)/2.0)*arrowThickness)
        CGContextClosePath(ctx)
        baseColor.setFill()
        CGContextSetLineWidth(ctx, 0.5)
        CGContextDrawPath(ctx, CGPathDrawingMode.FillStroke)
    }
    
    override func intrinsicContentSize() -> CGSize {
        return CGSize(width: 40, height: 40)
    }
}
