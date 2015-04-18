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
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) won't be implemented because I ain't using xibs")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let repeatButton = UIButton.buttonWithCustomBackground(RepeatIconView())
        repeatButton.addTarget(self, action: "repeatButtonPressed:", forControlEvents: UIControlEvents.TouchUpInside)
        view.addSubview(repeatButton)
        
        let menuButton = UIButton.buttonWithCustomBackground(MenuIconView())
        menuButton.addTarget(self, action: "menuButtonPressed:", forControlEvents: UIControlEvents.TouchUpInside)
        view.addSubview(menuButton)
        
        view.addConstraints(
            [
                NSLayoutConstraint(
                    item: menuButton,
                    attribute: .CenterX,
                    relatedBy: .Equal,
                    toItem: view,
                    attribute: .CenterX,
                    multiplier: 1.0 - 0.25,
                    constant: 0.0),
                NSLayoutConstraint(
                    item: repeatButton,
                    attribute: .CenterX,
                    relatedBy: .Equal,
                    toItem: view,
                    attribute: .CenterX,
                    multiplier: 1.0 + 0.25,
                    constant: 0.0),
                NSLayoutConstraint(
                    item: repeatButton,
                    attribute: .CenterY,
                    relatedBy: .Equal,
                    toItem: view,
                    attribute: .CenterY,
                    multiplier: 1.0,
                    constant: 0.0),
                NSLayoutConstraint(
                    item: menuButton,
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