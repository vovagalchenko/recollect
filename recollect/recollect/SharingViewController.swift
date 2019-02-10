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
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) won't be implemented because I ain't using xibs")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let repeatButton = UIButton.buttonWithCustomBackground(RepeatIconView())
        repeatButton.addTarget(
            self,
            action: #selector(SharingViewController.repeatButtonPressed(_:)),
            for: UIControl.Event.touchUpInside
        )
        view.addSubview(repeatButton)
        
        let menuButton = UIButton.buttonWithCustomBackground(MenuIconView())
        menuButton.addTarget(
            self,
            action: #selector(SharingViewController.menuButtonPressed(_:)),
            for: UIControl.Event.touchUpInside
        )
        view.addSubview(menuButton)
        
        view.addConstraints(
            [
                NSLayoutConstraint(
                    item: menuButton,
                    attribute: .centerX,
                    relatedBy: .equal,
                    toItem: view,
                    attribute: .centerX,
                    multiplier: 1.0 - 0.25,
                    constant: 0.0),
                NSLayoutConstraint(
                    item: repeatButton,
                    attribute: .centerX,
                    relatedBy: .equal,
                    toItem: view,
                    attribute: .centerX,
                    multiplier: 1.0 + 0.25,
                    constant: 0.0),
                NSLayoutConstraint(
                    item: repeatButton,
                    attribute: .centerY,
                    relatedBy: .equal,
                    toItem: view,
                    attribute: .centerY,
                    multiplier: 1.0,
                    constant: 0.0),
                NSLayoutConstraint(
                    item: menuButton,
                    attribute: .centerY,
                    relatedBy: .equal,
                    toItem: view,
                    attribute: .centerY,
                    multiplier: 1.0,
                    constant: 0.0),
            ]
        )
    }
    
    func withExistingDelegate(_ work: (SharingViewControllerDelegate) -> Void) {
        if let existingDelegate = delegate {
            work(existingDelegate)
        }
    }
    
    @objc func repeatButtonPressed(_ button: UIButton) {
        withExistingDelegate { $0.repeatButtonPressed(self) }
    }
    
    @objc func menuButtonPressed(_ button: UIButton) {
        withExistingDelegate { $0.menuButtonPressed(self) }
    }
}

protocol SharingViewControllerDelegate {
    func repeatButtonPressed(_ sharingVC: SharingViewController)
    func menuButtonPressed(_ sharingVC: SharingViewController)
}
