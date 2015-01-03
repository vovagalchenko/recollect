//
//  GameplayOutputViewController.swift
//  recollect
//
//  Created by Vova Galchenko on 1/1/15.
//  Copyright (c) 2015 Vova Galchenko. All rights reserved.
//

import UIKit

class GameplayOutputViewController: HalfScreenViewController {
    
    var gameState: GameState!
    
    private let progressViewHeight: CGFloat = 42.0
    private var progressVC: ProgressViewController?
    private var challengeContainer: UIView?
    private var challengeContainerXPositionConstraint: NSLayoutConstraint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        progressVC = ProgressViewController()
        progressVC?.gameState = gameState
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
        
        challengeContainer = UIView()
        challengeContainer!.setTranslatesAutoresizingMaskIntoConstraints(false)
        view.addSubview(challengeContainer!)
        
        view.addConstraints(
            [
                NSLayoutConstraint(
                    item: challengeContainer!,
                    attribute: NSLayoutAttribute.Top,
                    relatedBy: NSLayoutRelation.Equal,
                    toItem: view,
                    attribute: NSLayoutAttribute.Top,
                    multiplier: 1.0,
                    constant: 0.0),
                NSLayoutConstraint(
                    item: challengeContainer!,
                    attribute: NSLayoutAttribute.Bottom,
                    relatedBy: NSLayoutRelation.Equal,
                    toItem: progressVC!.view,
                    attribute: NSLayoutAttribute.Top,
                    multiplier: 1.0,
                    constant: 0.0),
                NSLayoutConstraint(
                    item: challengeContainer!,
                    attribute: NSLayoutAttribute.Width,
                    relatedBy: NSLayoutRelation.Equal,
                    toItem: view,
                    attribute: NSLayoutAttribute.Width,
                    multiplier: CGFloat(gameState.challenges.count)/CGFloat(gameState.n + 1),
                    constant: 0.0)
            ]
        )
        
        for (challengeIndex, challenge) in enumerate(gameState.challenges) {
            let topLabel = challengeLabel(challenge.lOperand)
            let bottomLabel = challengeLabel(challenge.rOperand)
            challengeContainer!.addSubview(topLabel)
            challengeContainer!.addSubview(bottomLabel)
            
            view.addConstraints(
                [
                    NSLayoutConstraint(
                        item: topLabel,
                        attribute: NSLayoutAttribute.CenterY,
                        relatedBy: NSLayoutRelation.Equal,
                        toItem: challengeContainer,
                        attribute: NSLayoutAttribute.CenterY,
                        multiplier: 2.0/3.0,
                        constant: 0.0),
                    NSLayoutConstraint(
                        item: bottomLabel,
                        attribute: NSLayoutAttribute.CenterY,
                        relatedBy: NSLayoutRelation.Equal,
                        toItem: challengeContainer,
                        attribute: NSLayoutAttribute.CenterY,
                        multiplier: 4.0/3.0,
                        constant: 0.0),
                    NSLayoutConstraint(
                        item: topLabel,
                        attribute: NSLayoutAttribute.CenterX,
                        relatedBy: NSLayoutRelation.Equal,
                        toItem: challengeContainer,
                        attribute: NSLayoutAttribute.CenterX,
                        multiplier: (2.0/CGFloat(gameState.challenges.count * 2)) * CGFloat(challengeIndex*2 + 1),
                        constant: 0.0),
                    NSLayoutConstraint(
                        item: bottomLabel,
                        attribute: NSLayoutAttribute.CenterX,
                        relatedBy: NSLayoutRelation.Equal,
                        toItem: topLabel,
                        attribute: NSLayoutAttribute.CenterX,
                        multiplier: 1.0,
                        constant: 0.0)
                ]
            )
        }
        
        setActiveChallenge(gameState.currentChallengeIndex, animated: false)
        
        GameManager.sharedInstance.subscribeToGameStateChangeNotifications(self)
    }
    
    deinit {
        GameManager.sharedInstance.unsubscribeFromGameStateChangeNotifications(self)
    }
    
    func challengeLabel(operand: Int) -> ManglableLabel {
        let label = ManglableLabel()
        label.setTranslatesAutoresizingMaskIntoConstraints(false)
        label.backgroundColor = UIColor.clearColor()
        label.textColor = DesignLanguage.NeverActiveTextColor
        label.font = UIFont(name: "AvenirNext-Regular", size: 76.0)
        label.text = "\(operand)"
        return label
    }
    
    func setActiveChallenge(challengeIndex: Int, animated: Bool) {
        view.layoutIfNeeded()
        setupChallengeContainerXPositionConstraint(challengeIndex)
        UIView.animateWithDuration(animated ? DesignLanguage.MinorAnimationDuration : 0.0, animations: { () -> Void in
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
        })
    }
    
    private func setupChallengeContainerXPositionConstraint(challengeIndex: Int) {
        if let constraintToRemove = challengeContainerXPositionConstraint {
            view.removeConstraint(constraintToRemove)
        }
        challengeContainerXPositionConstraint = NSLayoutConstraint(
            item: challengeContainer!,
            attribute: NSLayoutAttribute.Left,
            relatedBy: NSLayoutRelation.Equal,
            toItem: view,
            attribute: NSLayoutAttribute.Right,
            multiplier: -CGFloat(challengeIndex)/CGFloat(gameState.n + 1),
            constant: 0.0)
        view.addConstraint(challengeContainerXPositionConstraint!)
    }
    
    private func configureForTransition(animationState: TransitionAnimationState) {
        switch animationState {
            case TransitionAnimationState.Inactive:
                progressVC?.view.transform = CGAffineTransformMakeTranslation(0.0, progressViewHeight)
                challengeContainer?.transform = CGAffineTransformMakeTranslation(CGRectIntersection(view.bounds, challengeContainer!.frame).width, 0.0)
            case TransitionAnimationState.Active:
                progressVC?.view.transform = CGAffineTransformMakeTranslation(0.0, 0.0)
                challengeContainer?.transform = CGAffineTransformMakeTranslation(0.0, 0.0)
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

extension GameplayOutputViewController: GameStateChangeListener {
    func gameStateChanged(change: GameStateChange) {
        if change.oldGameState?.currentChallengeIndex != change.newGameState?.currentChallengeIndex {
            if let newChallengeIndex = change.newGameState?.currentChallengeIndex {
                setActiveChallenge(newChallengeIndex, animated: true)
            }
        }
        
        gameState = change.newGameState
    }
}