//
//  BlurView.swift
//  recollect
//
//  Created by Vova Galchenko on 1/3/15.
//  Copyright (c) 2015 Vova Galchenko. All rights reserved.
//

import UIKit

class BlurView: UIView {
    
    let blurRadius: CGFloat = 30
    var displayLink: CADisplayLink?
    var viewToBlur: UIView?
    var blurredView: UIImageView!
    var currentBlurredRectInBlurredViewsCoordinates: CGRect = CGRectZero
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        opaque = true
        self.backgroundColor = DesignLanguage.TopHalfBGColor
        setTranslatesAutoresizingMaskIntoConstraints(false)
        
        blurredView = UIImageView()
        blurredView.setTranslatesAutoresizingMaskIntoConstraints(false)
        blurredView.contentMode = UIViewContentMode.ScaleToFill
        addSubview(blurredView)
        addConstraints([
            NSLayoutConstraint(
                item: blurredView,
                attribute: NSLayoutAttribute.Top,
                relatedBy: NSLayoutRelation.Equal,
                toItem: self,
                attribute: NSLayoutAttribute.Top,
                multiplier: 1.0,
                constant: 0.0),
            NSLayoutConstraint(
                item: blurredView,
                attribute: NSLayoutAttribute.Bottom,
                relatedBy: NSLayoutRelation.Equal,
                toItem: self,
                attribute: NSLayoutAttribute.Bottom,
                multiplier: 1.0,
                constant: 0.0),
            NSLayoutConstraint(
                item: blurredView,
                attribute: NSLayoutAttribute.Left,
                relatedBy: NSLayoutRelation.Equal,
                toItem: self,
                attribute: NSLayoutAttribute.Left,
                multiplier: 1.0,
                constant: 0.0),
            NSLayoutConstraint(
                item: blurredView,
                attribute: NSLayoutAttribute.Right,
                relatedBy: NSLayoutRelation.Equal,
                toItem: self,
                attribute: NSLayoutAttribute.Right,
                multiplier: 1.0,
                constant: 0.0),
        ])
        
        let gradientView = GradientView(frame: CGRectZero)
        addSubview(gradientView)
        addConstraints([
            NSLayoutConstraint(
                item: gradientView,
                attribute: NSLayoutAttribute.Top,
                relatedBy: NSLayoutRelation.Equal,
                toItem: self,
                attribute: NSLayoutAttribute.Top,
                multiplier: 1.0,
                constant: 0.0),
            NSLayoutConstraint(
                item: gradientView,
                attribute: NSLayoutAttribute.Bottom,
                relatedBy: NSLayoutRelation.Equal,
                toItem: self,
                attribute: NSLayoutAttribute.Bottom,
                multiplier: 1.0,
                constant: 42.0),
            NSLayoutConstraint(
                item: gradientView,
                attribute: NSLayoutAttribute.Left,
                relatedBy: NSLayoutRelation.Equal,
                toItem: self,
                attribute: NSLayoutAttribute.Left,
                multiplier: 1.0,
                constant: 0.0),
            NSLayoutConstraint(
                item: gradientView,
                attribute: NSLayoutAttribute.Right,
                relatedBy: NSLayoutRelation.Equal,
                toItem: self,
                attribute: NSLayoutAttribute.Right,
                multiplier: 1.0,
                constant: 0.0),
        ])
    }
    
    override func willMoveToWindow(newWindow: UIWindow?) {
        if newWindow != nil {
            displayLink = CADisplayLink(target: self, selector: "refresh:")
            displayLink?.addToRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
        } else {
            displayLink?.invalidate()
        }
    }
    
    private func screenshotToBlur(rectInTargetsCoordinates: CGRect) -> CIImage {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, UIScreen.mainScreen().scale)
        let ctx = UIGraphicsGetCurrentContext()
        CGContextTranslateCTM(ctx, -rectInTargetsCoordinates.origin.x, -rectInTargetsCoordinates.origin.y)
        viewToBlur?.layer.presentationLayer().renderInContext(ctx)
        
        let uiImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return CIImage(CGImage: uiImage.CGImage)
    }
    
    private func treatImage(image: CIImage) -> UIImage {
        let context = CIContext(options: nil)!
        
        let blurFilter = CIFilter(name: "CIGaussianBlur")
        blurFilter.setValue(image, forKey: kCIInputImageKey)
        blurFilter.setValue(blurRadius, forKey: kCIInputRadiusKey)
        let blurredImage = blurFilter.outputImage
        let croppedBlurredImage = blurredImage.imageByCroppingToRect(
            CGRectMake(blurredImage.extent().origin.x + blurRadius*2, blurredImage.extent().origin.y + blurRadius*2, blurredImage.extent().width - (blurRadius * 4), blurredImage.extent().height - (blurRadius * 4))
        )
        
        return UIImage(CIImage: croppedBlurredImage)!
    }
    
    func refresh(displayLink: CADisplayLink) {
        let rectInTargetsCoordinates = viewToBlur!.layer.presentationLayer().convertRect(layer.presentationLayer().bounds, fromLayer:layer.presentationLayer() as CALayer)
        if !CGRectEqualToRect(rectInTargetsCoordinates, currentBlurredRectInBlurredViewsCoordinates)
            && CGRectIntersection(rectInTargetsCoordinates, viewToBlur!.layer.presentationLayer().bounds).width > 0 {
            let image = screenshotToBlur(rectInTargetsCoordinates)
            blurredView.image = treatImage(image)
            currentBlurredRectInBlurredViewsCoordinates = rectInTargetsCoordinates
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented. We don't expect it to ever get called because we're not using nibs.")
    }
}