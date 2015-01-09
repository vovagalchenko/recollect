//
//  GameplayButton.swift
//  recollect
//
//  Created by Vova Galchenko on 12/31/14.
//  Copyright (c) 2014 Vova Galchenko. All rights reserved.
//

import UIKit

class GameplayButton: UIControl {
    
    override var highlighted: Bool {
        didSet {
            if (highlighted) {
                label.textColor = DesignLanguage.InactiveTextColor
            } else if enabled {
                label.textColor = DesignLanguage.ActiveTextColor
            }
            setNeedsDisplay()
        }
    }
    
    override var enabled: Bool {
        didSet {
            if (enabled) {
                label.textColor = DesignLanguage.ActiveTextColor
            } else {
                label.textColor = DesignLanguage.InactiveTextColor
            }
        }
    }
    
    var text: String {
        get {
            return label.text ?? ""
        }
        set {
            label.text = newValue
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.opaque = false
        self.clearsContextBeforeDrawing = true
        self.clipsToBounds = false
        
        self.addSubview(label)
        self.addConstraints(
            NSLayoutConstraint.constraintsWithVisualFormat(
                "H:|[label]|",
                options: NSLayoutFormatOptions(0),
                metrics: nil,
                views: ["label": label]) +
            NSLayoutConstraint.constraintsWithVisualFormat(
                "V:|[label]|",
                options: NSLayoutFormatOptions(0),
                metrics: nil,
                views: ["label": label])
        )
    }
    
    override convenience init() {
        self.init(frame: CGRectZero)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented. We don't expect it to ever get called because we're not using nibs.")
    }
    
    override func intrinsicContentSize() -> CGSize {
        return CGSizeMake(UIViewNoIntrinsicMetric, UIViewNoIntrinsicMetric)
    }
    
    private lazy var label: ManglableLabel = {
        let label = ManglableLabel()
        label.backgroundColor = UIColor.clearColor()
        label.textColor = DesignLanguage.ActiveTextColor
        label.textAlignment = NSTextAlignment.Center
        label.font = UIFont(name: "AvenirNext-UltraLight", size: 54)
        label.setContentCompressionResistancePriority(1000, forAxis: UILayoutConstraintAxis.Vertical)
        label.setContentCompressionResistancePriority(1000, forAxis: UILayoutConstraintAxis.Horizontal)
        label.setContentHuggingPriority(250, forAxis: UILayoutConstraintAxis.Vertical)
        label.setContentHuggingPriority(250, forAxis: UILayoutConstraintAxis.Horizontal)
        return label
    }()
    
    private func lineInfo(lineWidthInPixels: CGFloat) -> (CGFloat, CGFloat) {
        let scale = window!.screen.scale
        let widthInPts = lineWidthInPixels/scale
        let offset = widthInPts/2
        return (widthInPts, offset)
    }
    
    override func drawRect(rect: CGRect) {
        let ctx = UIGraphicsGetCurrentContext()
        
        if (highlighted) {
            DesignLanguage.ShadowColor.setFill()
            CGContextFillRect(ctx, bounds)
        } else {
            let (whiteLineWidth, whiteLineOffset) = lineInfo(1.0)
            CGContextMoveToPoint(ctx, 0, whiteLineOffset)
            CGContextAddLineToPoint(ctx, bounds.size.width, whiteLineOffset)
            CGContextSetLineWidth(ctx, whiteLineWidth)
            DesignLanguage.HighlightColor.setStroke()
            CGContextStrokePath(ctx)
        }
        
        let (blackLineWidth, blackLineOffset) = lineInfo(2.0)
        CGContextMoveToPoint(ctx, 0, ceil(bounds.size.height) - blackLineOffset)
        CGContextAddLineToPoint(ctx, bounds.size.width, ceil(bounds.size.height) - blackLineOffset)
        CGContextSetLineWidth(ctx, blackLineWidth)
        DesignLanguage.ShadowColor.setStroke()
        CGContextStrokePath(ctx)
        
        let (blackVerticalLineWidth, blackVerticalLineOffset) = lineInfo(2.0)
        CGContextMoveToPoint(ctx, blackVerticalLineOffset, 0)
        CGContextAddLineToPoint(ctx, blackVerticalLineOffset, bounds.size.height)
        CGContextSetLineWidth(ctx, blackVerticalLineWidth)
        DesignLanguage.ShadowColor.setStroke()
        CGContextStrokePath(ctx)
    }
}