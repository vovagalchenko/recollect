//
//  BlurView.swift
//  recollect
//
//  Created by Vova Galchenko on 1/3/15.
//  Copyright (c) 2015 Vova Galchenko. All rights reserved.
//

import UIKit

class BlurView: UIView {
    let viewToBlur: UIView
    let blurredView: UIImageView
    let gradientView: GradientView
    
    init(viewToBlur: UIView) {
        self.viewToBlur = viewToBlur
        blurredView = UIImageView()
        blurredView.translatesAutoresizingMaskIntoConstraints = false
        gradientView = GradientView(frame: CGRectZero)
        super.init(frame: CGRectZero)
        
        opaque = true
        clipsToBounds = true
        backgroundColor = DesignLanguage.TopHalfBGColor
        translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(blurredView)
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
                constant: DesignLanguage.ProgressBarHeight),
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
    
    override func layoutSubviews() {
        let beforeRect = blurredView.bounds
        super.layoutSubviews()
        if !CGRectEqualToRect(beforeRect, blurredView.bounds) &&
            viewToBlur.bounds.width * viewToBlur.bounds.height > 0  {
            let blurredImage = self.treatImage(self.screenshot(self.viewToBlur))
            self.blurredView.image = blurredImage
        }
    }
    
    private func screenshot(viewToCapture: UIView) -> CIImage {
        UIGraphicsBeginImageContextWithOptions(viewToCapture.bounds.size, false, UIScreen.mainScreen().scale)
        let ctx = UIGraphicsGetCurrentContext()!
        viewToCapture.layer.renderInContext(ctx)
        
        let uiImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return CIImage(CGImage: uiImage.CGImage!)
    }
    
    private func treatImage(image: CIImage) -> UIImage {
        let blurFilter = CIFilter(name: "CIGaussianBlur")!
        blurFilter.setValue(image, forKey: kCIInputImageKey)
        blurFilter.setValue(DesignLanguage.obfuscationBlurRadius, forKey: kCIInputRadiusKey)
        let blurredImage = blurFilter.outputImage!
        let originalImageExtent = image.extent
        let blurredImageExtent = blurredImage.extent
        let centerOfImage = CGPoint(x: blurredImageExtent.midX, y: blurredImageExtent.midY)
        
        let croppedBlurredImage = blurredImage.imageByCroppingToRect(
            CGRectMake(
                centerOfImage.x - blurredImageExtent.width/2,
                centerOfImage.y - originalImageExtent.height/2,
                blurredImageExtent.width,
                originalImageExtent.height
            )
        )
        
        return UIImage(CIImage: croppedBlurredImage, scale: UIScreen.mainScreen().scale, orientation: UIImageOrientation.Up)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented. We don't expect it to ever get called because we're not using nibs.")
    }
}