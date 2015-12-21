//
//  UIView+PixelPerfect.swift
//  recollect
//
//  Created by Vova Galchenko on 1/11/15.
//  Copyright (c) 2015 Vova Galchenko. All rights reserved.
//

import UIKit

extension UIView {
    func pixelPerfectCoordinates(thicknessInPixels thicknessInPixels: Int, points: CGPoint...) -> ([CGPoint], CGFloat) {
        assert(window != nil, "A view must be added to a window before you can get pixel perfect coordinates for points.")
        let pixelsPerPoint = window!.screen.scale
        let thicknessInPoints = CGFloat(thicknessInPixels)/pixelsPerPoint
        
        func applyOffset(coordinate: CGFloat, limit: CGFloat, thicknessInPoints: CGFloat) -> CGFloat {
            let nearestPointBoundary = round(coordinate)
            var result = nearestPointBoundary + (thicknessInPoints/CGFloat(2.0))
            if nearestPointBoundary > coordinate {
                result = nearestPointBoundary - (thicknessInPoints/CGFloat(2.0))
            }
            // Edge cases (literally)
            result = max(thicknessInPoints/CGFloat(2.0), result)
            result = min(limit - thicknessInPoints/CGFloat(2.0), result)
            return result
        }
        
        let resultingPoints = points.map { CGPoint(
            x: applyOffset($0.x, limit: self.bounds.width, thicknessInPoints: thicknessInPoints),
            y: applyOffset($0.y, limit: self.bounds.height, thicknessInPoints: thicknessInPoints)
        ) }
        return (resultingPoints, thicknessInPoints)
    }
    
    
}
