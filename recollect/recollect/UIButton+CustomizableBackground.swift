//
//  UIButton+CustomizableBackground.swift
//  recollect
//
//  Created by Vova Galchenko on 1/7/15.
//  Copyright (c) 2015 Vova Galchenko. All rights reserved.
//

import UIKit

extension UIButton {
    class func buttonWithCustomBackground(bg: ButtonBackground) -> UIButton {
        let button = UIButton(type: UIButtonType.Custom)
        button.addTarget(button, action: "didBecomePressed:", forControlEvents: [.TouchDown, .TouchDragEnter])
        button.addTarget(button, action: "didBecomeUnpressed:", forControlEvents: [.TouchDragExit, .TouchUpInside])
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addSubview(bg)
        button.addConstraints(
            NSLayoutConstraint.constraintsWithVisualFormat(
                "H:|[bg]|",
                options: NSLayoutFormatOptions(rawValue: 0),
                metrics: nil,
                views: ["bg" : bg]) +
            NSLayoutConstraint.constraintsWithVisualFormat(
                "V:|[bg]|",
                options: NSLayoutFormatOptions(rawValue: 0),
                metrics: nil,
                views: ["bg" : bg])
        )
        return button
    }
    
    func actOnButtonBackground(work: (ButtonBackground) -> Void) {
        for subview in subviews {
            if let customButtonBg = subview as? ButtonBackground {
                work(customButtonBg)
            }
        }
    }
    
    func didBecomePressed(button: UIButton) {
        actOnButtonBackground { $0.baseColor = DesignLanguage.InactiveTextColor }
    }
    
    func didBecomeUnpressed(button: UIButton) {
        actOnButtonBackground { $0.baseColor = DesignLanguage.ActiveTextColor }
    }
}
