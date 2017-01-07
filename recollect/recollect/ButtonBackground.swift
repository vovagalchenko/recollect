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
    
    init() {
        self.baseColor = DesignLanguage.ActiveTextColor
        super.init(frame: CGRect.zero)
        translatesAutoresizingMaskIntoConstraints = false
        isUserInteractionEnabled = false
        isOpaque = false
        clearsContextBeforeDrawing = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) is not expected to be called, because we don't use xibs")
    }
}
