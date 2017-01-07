//
//  GradientView.swift
//  recollect
//
//  Created by Vova Galchenko on 1/3/15.
//  Copyright (c) 2015 Vova Galchenko. All rights reserved.
//

import UIKit

class GradientView: UIView {
    
    let gradient: CGGradient
    
    override init(frame: CGRect) {
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        gradient = CGGradient(colorSpace: colorSpace, colorComponents: [
            0.0, 0.0, 0.0, 0.0,
            0.0, 0.0, 0.0, 0.2
        ], locations: [0.0, 1.0], count: 2)!
        
        super.init(frame: frame)
        isOpaque = false
        clearsContextBeforeDrawing = true
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented. We don't expect it to ever get called because we're not using nibs.")
    }
    
    override func draw(_ rect: CGRect) {
        let ctx = UIGraphicsGetCurrentContext()
        ctx?.drawLinearGradient(gradient, start: CGPoint(x: 0, y: 0), end: CGPoint(x: 0, y: bounds.size.height), options: [])
        
        ctx?.move(to: CGPoint(x: bounds.size.width, y: 0.0))
        ctx?.addLine(to: CGPoint(x: bounds.size.width, y: bounds.size.height))
        
        ctx?.setLineWidth(2.0)
        DesignLanguage.ShadowColor.setStroke()
        ctx?.strokePath()
    }
}
