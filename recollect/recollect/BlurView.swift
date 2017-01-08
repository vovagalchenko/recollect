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
        gradientView = GradientView(frame: CGRect.zero)
        super.init(frame: CGRect.zero)
        
        isOpaque = true
        clipsToBounds = true
        backgroundColor = DesignLanguage.TopHalfBGColor
        translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(blurredView)
        addSubview(gradientView)
        
        addConstraints([
            NSLayoutConstraint(
                item: gradientView,
                attribute: NSLayoutAttribute.top,
                relatedBy: NSLayoutRelation.equal,
                toItem: self,
                attribute: NSLayoutAttribute.top,
                multiplier: 1.0,
                constant: 0.0),
            NSLayoutConstraint(
                item: gradientView,
                attribute: NSLayoutAttribute.bottom,
                relatedBy: NSLayoutRelation.equal,
                toItem: self,
                attribute: NSLayoutAttribute.bottom,
                multiplier: 1.0,
                constant: DesignLanguage.ProgressBarHeight),
            NSLayoutConstraint(
                item: gradientView,
                attribute: NSLayoutAttribute.left,
                relatedBy: NSLayoutRelation.equal,
                toItem: self,
                attribute: NSLayoutAttribute.left,
                multiplier: 1.0,
                constant: 0.0),
            NSLayoutConstraint(
                item: gradientView,
                attribute: NSLayoutAttribute.right,
                relatedBy: NSLayoutRelation.equal,
                toItem: self,
                attribute: NSLayoutAttribute.right,
                multiplier: 1.0,
                constant: 0.0),
        ])
    }
    
    override func layoutSubviews() {
        let beforeRect = blurredView.bounds
        super.layoutSubviews()
        if !beforeRect.equalTo(blurredView.bounds) &&
            viewToBlur.bounds.width * viewToBlur.bounds.height > 0  {
            let blurredImage = self.treatImage(self.screenshot(self.viewToBlur))
            self.blurredView.image = blurredImage
        }
    }
    
    private func screenshot(_ viewToCapture: UIView) -> CIImage {
        UIGraphicsBeginImageContextWithOptions(viewToCapture.bounds.size, false, UIScreen.main.scale)
        let ctx = UIGraphicsGetCurrentContext()!
        viewToCapture.layer.render(in: ctx)
        
        let uiImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return CIImage(cgImage: uiImage!.cgImage!)
    }
    
    private func treatImage(_ image: CIImage) -> UIImage {
        let blurFilter = CIFilter(name: "CIGaussianBlur")!
        blurFilter.setValue(image, forKey: kCIInputImageKey)
        blurFilter.setValue(DesignLanguage.obfuscationBlurRadius, forKey: kCIInputRadiusKey)
        let blurredImage = blurFilter.outputImage!
        let originalImageExtent = image.extent
        let blurredImageExtent = blurredImage.extent
        let centerOfImage = CGPoint(x: blurredImageExtent.midX, y: blurredImageExtent.midY)
        
        let croppedBlurredImage = blurredImage.cropping(
            to: CGRect(
                x: centerOfImage.x - originalImageExtent.width/2,
                y: centerOfImage.y - originalImageExtent.height/2,
                width: originalImageExtent.width,
                height: originalImageExtent.height
            )
        )
        
        return UIImage(ciImage: croppedBlurredImage, scale: UIScreen.main.scale, orientation: UIImageOrientation.up)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented. We don't expect it to ever get called because we're not using nibs.")
    }
}
