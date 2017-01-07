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
        
        isOpaque = false
        clearsContextBeforeDrawing = true
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    convenience init() {
        self.init(frame: CGRect.zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented. We don't expect it to ever get called because we're not using nibs.")
    }
    
    override func draw(_ rect: CGRect) {
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
        
        ctx?.addPath(roundedRectPath.cgPath)
        ctx?.setLineDash(phase: 0, lengths: [1.0, 1.0])
        ctx?.setLineWidth(lineThickness)
        DesignLanguage.AccentTextColor.setStroke()
        ctx?.strokePath()
    }
    
}
