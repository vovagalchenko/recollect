//
//  ButtonBackground.swift
//  recollect
//
//  Created by Vova Galchenko on 1/7/15.
//  Copyright (c) 2015 Vova Galchenko. All rights reserved.
//

import UIKit

class ButtonBackground: UIView {
    var baseColor: UIColor {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override init() {
        self.baseColor = DesignLanguage.ActiveTextColor
        super.init(frame: CGRectZero)
        setTranslatesAutoresizingMaskIntoConstraints(false)
        userInteractionEnabled = false
        opaque = false
        clearsContextBeforeDrawing = true
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) is not expected to be called, because we don't use xibs")
    }
}