//
//  RepeatView.swift
//  recollect
//
//  Created by Vova Galchenko on 1/7/15.
//  Copyright (c) 2015 Vova Galchenko. All rights reserved.
//

import UIKit

class RepeatView: UIView {
    
    var arrowColor: UIColor = DesignLanguage.ActiveTextColor
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setTranslatesAutoresizingMaskIntoConstraints(false)
        opaque = false
        clearsContextBeforeDrawing = true
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) isn't expected to be called, because we're not using xibs.")
    }
    
    override func drawRect(rect: CGRect) {
        let ctx = UIGraphicsGetCurrentContext()
        
        let boundingBoxDimension = min(rect.height, rect.width)
        let origin = CGPoint(x: CGRectGetMidX(rect) - boundingBoxDimension/2.0, y: CGRectGetMidY(rect) - boundingBoxDimension/2.0)
        let arrowThickness = boundingBoxDimension/6.0
        
        CGContextAddArc(
            ctx,
            CGRectGetMidX(rect),
            CGRectGetMidY(rect),
            boundingBoxDimension/2.0 - arrowThickness,
            0,
            CGFloat(0.9*(M_PI*2.0)),
            0)
        CGContextSetLineWidth(ctx, arrowThickness)
        arrowColor.setStroke()
        CGContextStrokePath(ctx)
    }
    
    override func intrinsicContentSize() -> CGSize {
        return CGSize(width: 30, height: 30)
    }
}
