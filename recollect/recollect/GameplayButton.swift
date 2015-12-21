//
//  GameplayButton.swift
//  recollect
//
//  Created by Vova Galchenko on 12/31/14.
//  Copyright (c) 2014 Vova Galchenko. All rights reserved.
//

import UIKit
import QuartzCore

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
            setUpGlow()
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
    
    var glowWhenEnabled: Bool = false {
        didSet {
            setUpGlow()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.opaque = false
        self.clearsContextBeforeDrawing = true
        self.clipsToBounds = false
        
        self.addSubview(label)
        self.addConstraints(
            NSLayoutConstraint.constraintsWithVisualFormat(
                "H:|[label]|",
                options: NSLayoutFormatOptions(rawValue: 0),
                metrics: nil,
                views: ["label": label]) +
            NSLayoutConstraint.constraintsWithVisualFormat(
                "V:|[label]|",
                options: NSLayoutFormatOptions(rawValue: 0),
                metrics: nil,
                views: ["label": label])
        )
    }
    
    convenience init() {
        self.init(frame: CGRectZero)
    }
    
    private func setUpGlow() {
        label.layer.removeAllAnimations()
        if (enabled && glowWhenEnabled) {
            glow()
        }
    }
    
    private func glow() {
        label.layer.shadowColor = label.textColor.CGColor
        label.layer.shadowRadius = 0.0
        label.layer.shadowOpacity = 1.0
        label.layer.shadowOffset = CGSizeZero
        
        label.layer.transform = CATransform3DIdentity
        
        let scaleAnimation = CABasicAnimation(keyPath: "transform")
        scaleAnimation.toValue = NSValue(CATransform3D: CATransform3DMakeScale(1.3, 1.3, 1.0))
        
        let glowAnimation = CABasicAnimation(keyPath: "shadowRadius")
        glowAnimation.toValue = 5.0
        
        let animationGroup = CAAnimationGroup()
        animationGroup.duration = 0.5
        animationGroup.autoreverses = true
        animationGroup.repeatCount = 1.0
        animationGroup.delegate = self
        animationGroup.animations = [scaleAnimation, glowAnimation]
        label.layer.addAnimation(animationGroup, forKey: nil)
    }
    
    override func animationDidStop(anim: CAAnimation, finished flag: Bool) {
        if flag {
            setUpGlow()
        }
    }

    required init?(coder aDecoder: NSCoder) {
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
    
    override func drawRect(rect: CGRect) {
        let ctx = UIGraphicsGetCurrentContext()
        
        if (highlighted) {
            DesignLanguage.ShadowColor.setFill()
            CGContextFillRect(ctx, bounds)
        } else {
            let (highlightPoints, highlightLineWidth) = pixelPerfectCoordinates(thicknessInPixels: 1, points: CGPoint(x: 0, y: 0), CGPoint(x: bounds.width, y: 0))
            CGContextMoveToPoint(ctx, highlightPoints[0].x, highlightPoints[0].y)
            CGContextAddLineToPoint(ctx, highlightPoints[1].x, highlightPoints[1].y)
            CGContextSetLineWidth(ctx, highlightLineWidth)
            DesignLanguage.HighlightColor.setStroke()
            CGContextStrokePath(ctx)
        }
        
        
        let (horizontalShadowPoints, horizontalShadowWidth) = pixelPerfectCoordinates(thicknessInPixels: 2, points: CGPoint(x: 0, y: bounds.size.height), CGPoint(x: bounds.size.width, y: bounds.size.height))
        CGContextMoveToPoint(ctx, horizontalShadowPoints[0].x, horizontalShadowPoints[0].y)
        CGContextAddLineToPoint(ctx, horizontalShadowPoints[1].x, horizontalShadowPoints[1].y)
        CGContextSetLineWidth(ctx, horizontalShadowWidth)
        DesignLanguage.ShadowColor.setStroke()
        CGContextStrokePath(ctx)
        
        
        let (verticalShadowPoints, verticalLineWidth) = pixelPerfectCoordinates(thicknessInPixels: 2, points: CGPoint(x: 0, y: 0), CGPoint(x: 0, y: bounds.height))
        CGContextMoveToPoint(ctx, verticalShadowPoints[0].x, verticalShadowPoints[0].y)
        CGContextAddLineToPoint(ctx, verticalShadowPoints[1].x, verticalShadowPoints[1].y)
        CGContextSetLineWidth(ctx, verticalLineWidth)
        DesignLanguage.ShadowColor.setStroke()
        CGContextStrokePath(ctx)
    }
}