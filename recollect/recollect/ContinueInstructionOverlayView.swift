//
//  ContinueInstructionOverlayView.swift
//  recollect
//
//  Created by Vova Galchenko on 1/11/15.
//  Copyright (c) 2015 Vova Galchenko. All rights reserved.
//

import UIKit

class ContinueInstructionOverlayView: UIView {
    
    let instructionLabel: ManglableLabel
    
    override init(frame: CGRect) {
        instructionLabel = ManglableLabel()
        instructionLabel.backgroundColor = UIColor.clear
        instructionLabel.textColor = DesignLanguage.BottomHalfBGColor
        instructionLabel.font = UIFont(name: "HelveticaNeue", size: 28.8)
        instructionLabel.numberOfLines = 2
        instructionLabel.text = "Memorize challenge,\nthen press continue"
        instructionLabel.textAlignment = NSTextAlignment.center
        super.init(frame: frame)
        
        isUserInteractionEnabled = false
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = UIColor.white.withAlphaComponent(0.2)
        
        addSubview(instructionLabel)
        addConstraints([
            NSLayoutConstraint(
                item: instructionLabel,
                attribute: NSLayoutAttribute.centerX,
                relatedBy: NSLayoutRelation.equal,
                toItem: self,
                attribute: NSLayoutAttribute.centerX,
                multiplier: 1.0,
                constant: 0.0),
            NSLayoutConstraint(
                item: instructionLabel,
                attribute: NSLayoutAttribute.centerY,
                relatedBy: NSLayoutRelation.equal,
                toItem: self,
                attribute: NSLayoutAttribute.centerY,
                multiplier: 1.0,
                constant: 0.0)
        ])
    }
    
    convenience init() {
        self.init(frame: CGRect.zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented. We don't expect it to ever get called because we're not using nibs.")
    }
}
