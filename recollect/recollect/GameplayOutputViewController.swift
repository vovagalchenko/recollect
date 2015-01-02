//
//  GameplayOutputViewController.swift
//  recollect
//
//  Created by Vova Galchenko on 1/1/15.
//  Copyright (c) 2015 Vova Galchenko. All rights reserved.
//

import UIKit

class GameplayOutputViewController: HalfScreenViewController {
    
    let progressViewHeight: CGFloat = 42.0
    var progressVC: ProgressViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        progressVC = ProgressViewController()
        addChildViewController(progressVC!)
        view.addSubview(progressVC!.view)
        progressVC!.didMoveToParentViewController(self)
        
        view.addConstraints(
            NSLayoutConstraint.constraintsWithVisualFormat(
                "H:|[progressView]|",
                options: NSLayoutFormatOptions(0),
                metrics: nil,
                views: ["progressView" : progressVC!.view]) +
            NSLayoutConstraint.constraintsWithVisualFormat(
                "V:[progressView(\(progressViewHeight))]|",
                options: NSLayoutFormatOptions(0),
                metrics: nil,
                views: ["progressView" : progressVC!.view])
        )
    }
    
    private func configureForTransition(animationState: TransitionAnimationState) {
        switch animationState {
            case TransitionAnimationState.Inactive:
                progressVC?.view.transform = CGAffineTransformMakeTranslation(0.0, progressViewHeight)
            case TransitionAnimationState.Active:
                progressVC?.view.transform = CGAffineTransformMakeTranslation(0.0, 0.0)
        }
    }
    
    override func animationWillBegin(beginningState: TransitionAnimationState, plannedAnimationDuration: NSTimeInterval) {
        super.animationWillBegin(beginningState, plannedAnimationDuration: plannedAnimationDuration)
        configureForTransition(beginningState)
    }
    
    override func addToAnimationBlock(endingState: TransitionAnimationState) {
        configureForTransition(endingState)
    }
    
    override func managesOwnTransitions() -> Bool {
        return true
    }
}