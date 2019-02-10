//
//  GameplayButton.swift
//  recollect
//
//  Created by Vova Galchenko on 12/31/14.
//  Copyright (c) 2014 Vova Galchenko. All rights reserved.
//

import UIKit
import QuartzCore

class GameplayButton: UIControl, CAAnimationDelegate {
    
    override var isHighlighted: Bool {
        didSet {
            if (isHighlighted) {
                label.textColor = DesignLanguage.InactiveTextColor
            } else if isEnabled {
                label.textColor = DesignLanguage.ActiveTextColor
            }
            setNeedsDisplay()
        }
    }
    
    override var isEnabled: Bool {
        didSet {
            if (isEnabled) {
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
        self.isOpaque = false
        self.clearsContextBeforeDrawing = true
        self.clipsToBounds = false
        
        self.addSubview(label)
        self.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "H:|[label]|",
                options: NSLayoutConstraint.FormatOptions(rawValue: 0),
                metrics: nil,
                views: ["label": label]) +
            NSLayoutConstraint.constraints(
                withVisualFormat: "V:|[label]|",
                options: NSLayoutConstraint.FormatOptions(rawValue: 0),
                metrics: nil,
                views: ["label": label])
        )
    }
    
    convenience init() {
        self.init(frame: CGRect.zero)
    }
    
    private func setUpGlow() {
        label.layer.removeAllAnimations()
        if (isEnabled && glowWhenEnabled) {
            glow()
        }
    }
    
    private func glow() {
        label.layer.shadowColor = label.textColor.cgColor
        label.layer.shadowRadius = 0.0
        label.layer.shadowOpacity = 1.0
        label.layer.shadowOffset = CGSize.zero
        
        label.layer.transform = CATransform3DIdentity
        
        let scaleAnimation = CABasicAnimation(keyPath: "transform")
        scaleAnimation.toValue = NSValue(caTransform3D: CATransform3DMakeScale(1.3, 1.3, 1.0))
        
        let glowAnimation = CABasicAnimation(keyPath: "shadowRadius")
        glowAnimation.toValue = 5.0
        
        let animationGroup = CAAnimationGroup()
        animationGroup.duration = 0.5
        animationGroup.autoreverses = true
        animationGroup.repeatCount = 1.0
        animationGroup.delegate = self
        animationGroup.animations = [scaleAnimation, glowAnimation]
        label.layer.add(animationGroup, forKey: nil)
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if flag {
            setUpGlow()
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented. We don't expect it to ever get called because we're not using nibs.")
    }
    
    override var intrinsicContentSize : CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: UIView.noIntrinsicMetric)
    }
    
    private lazy var label: ManglableLabel = {
        let label = ManglableLabel()
        label.backgroundColor = UIColor.clear
        label.textColor = DesignLanguage.ActiveTextColor
        label.textAlignment = NSTextAlignment.center
        label.font = UIFont(name: "AvenirNext-UltraLight", size: 54)
        label.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 1000), for: NSLayoutConstraint.Axis.vertical)
        label.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 1000), for: NSLayoutConstraint.Axis.horizontal)
        label.setContentHuggingPriority(UILayoutPriority(rawValue: 250), for: NSLayoutConstraint.Axis.vertical)
        label.setContentHuggingPriority(UILayoutPriority(rawValue: 250), for: NSLayoutConstraint.Axis.horizontal)
        return label
    }()
    
    override func draw(_ rect: CGRect) {
        let ctx = UIGraphicsGetCurrentContext()
        
        if (isHighlighted) {
            DesignLanguage.ShadowColor.setFill()
            ctx?.fill(bounds)
        } else {
            let (highlightPoints, highlightLineWidth) = pixelPerfectCoordinates(thicknessInPixels: 1, points: CGPoint(x: 0, y: 0), CGPoint(x: bounds.width, y: 0))
            ctx?.move(to: CGPoint(x: highlightPoints[0].x, y: highlightPoints[0].y))
            ctx?.addLine(to: CGPoint(x: highlightPoints[1].x, y: highlightPoints[1].y))
            ctx?.setLineWidth(highlightLineWidth)
            DesignLanguage.HighlightColor.setStroke()
            ctx?.strokePath()
        }
        
        
        let (horizontalShadowPoints, horizontalShadowWidth) = pixelPerfectCoordinates(thicknessInPixels: 2, points: CGPoint(x: 0, y: bounds.size.height), CGPoint(x: bounds.size.width, y: bounds.size.height))
        ctx?.move(to: CGPoint(x: horizontalShadowPoints[0].x, y: horizontalShadowPoints[0].y))
        ctx?.addLine(to: CGPoint(x: horizontalShadowPoints[1].x, y: horizontalShadowPoints[1].y))
        ctx?.setLineWidth(horizontalShadowWidth)
        DesignLanguage.ShadowColor.setStroke()
        ctx?.strokePath()
        
        
        let (verticalShadowPoints, verticalLineWidth) = pixelPerfectCoordinates(thicknessInPixels: 2, points: CGPoint(x: 0, y: 0), CGPoint(x: 0, y: bounds.height))
        ctx?.move(to: CGPoint(x: verticalShadowPoints[0].x, y: verticalShadowPoints[0].y))
        ctx?.addLine(to: CGPoint(x: verticalShadowPoints[1].x, y: verticalShadowPoints[1].y))
        ctx?.setLineWidth(verticalLineWidth)
        DesignLanguage.ShadowColor.setStroke()
        ctx?.strokePath()
    }
}
