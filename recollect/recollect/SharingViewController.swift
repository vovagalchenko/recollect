//
//  SharingViewController.swift
//  recollect
//
//  Created by Vova Galchenko on 1/6/15.
//  Copyright (c) 2015 Vova Galchenko. All rights reserved.
//

import UIKit

class SharingViewController: HalfScreenViewController {
    let gameState: GameState
    
    init(gameState: GameState) {
        self.gameState = gameState
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let backButton = UIButton.buttonWithType(UIButtonType.Custom) as UIButton
        backButton.setTranslatesAutoresizingMaskIntoConstraints(false)
        let backButtonBg = RepeatView(frame: CGRectZero)
        backButton.addSubview(backButtonBg)
        
        backButton.addConstraints(
            NSLayoutConstraint.constraintsWithVisualFormat(
                "H:|[bg]|",
                options: NSLayoutFormatOptions(0),
                metrics: nil,
                views: ["bg" : backButtonBg]) +
            NSLayoutConstraint.constraintsWithVisualFormat(
                "V:|[bg]|",
                options: NSLayoutFormatOptions(0),
                metrics: nil,
                views: ["bg" : backButtonBg])
        )
        
        view.addSubview(backButton)
        
        view.addConstraints(
            [
                NSLayoutConstraint(
                    item: backButton,
                    attribute: .CenterX,
                    relatedBy: .Equal,
                    toItem: view,
                    attribute: .CenterX,
                    multiplier: 1.0,
                    constant: 0.0),
                NSLayoutConstraint(
                    item: backButton,
                    attribute: .CenterY,
                    relatedBy: .Equal,
                    toItem: view,
                    attribute: .CenterY,
                    multiplier: 1.0,
                    constant: 0.0),
            ]
        )
    }
}
