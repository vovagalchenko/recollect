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
    var delegate: SharingViewControllerDelegate?
    
    init(gameState: GameState) {
        self.gameState = gameState
        self.delegate = GameManager.sharedInstance
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let backButton = UIButton.buttonWithCustomBackground(RepeatView())
        backButton.userInteractionEnabled = true
        backButton.addTarget(self, action: "repeatButtonPressed:", forControlEvents: UIControlEvents.TouchUpInside)
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
    
    func withExistingDelegate(work: (SharingViewControllerDelegate) -> Void) {
        if let existingDelegate = delegate {
            work(existingDelegate)
        }
    }
    
    func repeatButtonPressed(button: UIButton) {
        withExistingDelegate { $0.repeatButtonPressed(self) }
    }
    
    func menuButtonPressed(button: UIButton) {
        withExistingDelegate { $0.menuButtonPressed(self) }
    }
}

protocol SharingViewControllerDelegate {
    func repeatButtonPressed(sharingVC: SharingViewController)
    func menuButtonPressed(sharingVC: SharingViewController)
}