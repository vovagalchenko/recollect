//
//  UIButton+CustomizableBackground.swift
//  recollect
//
//  Created by Vova Galchenko on 1/7/15.
//  Copyright (c) 2015 Vova Galchenko. All rights reserved.
//

import UIKit

extension UIButton {
    class func buttonWithCustomBackground(_ bg: ButtonBackground) -> UIButton {
        let button = UIButton(type: UIButton.ButtonType.custom)
        button.addTarget(button, action: #selector(UIButton.didBecomePressed(_:)), for: [.touchDown, .touchDragEnter])
        button.addTarget(button, action: #selector(UIButton.didBecomeUnpressed(_:)), for: [.touchDragExit, .touchUpInside])
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addSubview(bg)
        button.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "H:|[bg]|",
                options: NSLayoutConstraint.FormatOptions(rawValue: 0),
                metrics: nil,
                views: ["bg" : bg]) +
            NSLayoutConstraint.constraints(
                withVisualFormat: "V:|[bg]|",
                options: NSLayoutConstraint.FormatOptions(rawValue: 0),
                metrics: nil,
                views: ["bg" : bg])
        )
        return button
    }
    
    func actOnButtonBackground(_ work: (ButtonBackground) -> Void) {
        for subview in subviews {
            if let customButtonBg = subview as? ButtonBackground {
                work(customButtonBg)
            }
        }
    }
    
    @objc func didBecomePressed(_ button: UIButton) {
        actOnButtonBackground { $0.baseColor = DesignLanguage.InactiveTextColor }
    }
    
    @objc func didBecomeUnpressed(_ button: UIButton) {
        actOnButtonBackground { $0.baseColor = DesignLanguage.ActiveTextColor }
    }
}
