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
    
    private var plusLabel: UILabel?
    private var progressVC: ProgressViewController?
    private var challengeContainer: UIView?
    private var blurView: BlurView?
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
                "V:[progressView(\(DesignLanguage.ProgressBarHeight))]|",
                options: NSLayoutFormatOptions(0),
                metrics: nil,
                views: ["progressView" : progressVC!.view])
        )
        
        challengeContainer = UIView()
        challengeContainer!.backgroundColor = DesignLanguage.TopHalfBGColor
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
        
        blurView = BlurView(viewToBlur: challengeContainer!)
        view.addSubview(blurView!)
        
        view.addConstraints([
            NSLayoutConstraint(
                item: blurView!.blurredView,
                attribute: NSLayoutAttribute.CenterY,
                relatedBy: NSLayoutRelation.Equal,
                toItem: challengeContainer,
                attribute: NSLayoutAttribute.CenterY,
                multiplier: 1.0,
                constant: 0.0),
            NSLayoutConstraint(
                item: blurView!.blurredView,
                attribute: NSLayoutAttribute.Height,
                relatedBy: NSLayoutRelation.Equal,
                toItem: challengeContainer,
                attribute: NSLayoutAttribute.Height,
                multiplier:1.0,
                constant: 0.0),
            NSLayoutConstraint(
                item: blurView!.blurredView,
                attribute: NSLayoutAttribute.Left,
                relatedBy: NSLayoutRelation.Equal,
                toItem: challengeContainer,
                attribute: NSLayoutAttribute.Left,
                multiplier: 1.0,
                constant: 0.0),
            NSLayoutConstraint(
                item: blurView!.blurredView,
                attribute: NSLayoutAttribute.Right,
                relatedBy: NSLayoutRelation.Equal,
                toItem: challengeContainer,
                attribute: NSLayoutAttribute.Right,
                multiplier: 1.0,
                constant: 0.0),
            ])
        
        view.addConstraints(
            [
                NSLayoutConstraint(
                    item: blurView!,
                    attribute: NSLayoutAttribute.Top,
                    relatedBy: NSLayoutRelation.Equal,
                    toItem: view,
                    attribute: NSLayoutAttribute.Top,
                    multiplier: 1.0,
                    constant: 0.0),
                NSLayoutConstraint(
                    item: blurView!,
                    attribute: NSLayoutAttribute.Bottom,
                    relatedBy: NSLayoutRelation.Equal,
                    toItem: view,
                    attribute: NSLayoutAttribute.Bottom,
                    multiplier: 1.0,
                    constant: 0.0),
                NSLayoutConstraint(
                    item: blurView!,
                    attribute: NSLayoutAttribute.Left,
                    relatedBy: NSLayoutRelation.Equal,
                    toItem: view,
                    attribute: NSLayoutAttribute.Left,
                    multiplier: 1.0,
                    constant: 0.0),
                NSLayoutConstraint(
                    item: blurView!,
                    attribute: NSLayoutAttribute.Right,
                    relatedBy: NSLayoutRelation.Equal,
                    toItem: view,
                    attribute: NSLayoutAttribute.Right,
                    multiplier: CGFloat(gameState.n)/CGFloat(gameState.n + 1),
                    constant: 0.0),
            ]
        )
        
        plusLabel = UILabel()
        plusLabel!.setTranslatesAutoresizingMaskIntoConstraints(false)
        plusLabel!.backgroundColor = UIColor.clearColor()
        plusLabel!.textColor = DesignLanguage.NeverActiveTextColor
        plusLabel!.font = UIFont(name: "AvenirNext-Regular", size: 45.0)
        plusLabel!.text = "+"
        view.addSubview(plusLabel!)
        
        view.addConstraints(
            [
                NSLayoutConstraint(
                    item: plusLabel!,
                    attribute: NSLayoutAttribute.CenterY,
                    relatedBy: NSLayoutRelation.Equal,
                    toItem: challengeContainer,
                    attribute: NSLayoutAttribute.CenterY,
                    multiplier: 1.0,
                    constant: 0.0),
                NSLayoutConstraint(
                    item: plusLabel!,
                    attribute: NSLayoutAttribute.CenterX,
                    relatedBy: NSLayoutRelation.Equal,
                    toItem: view,
                    attribute: NSLayoutAttribute.Right,
                    multiplier: (CGFloat(gameState.n) + 0.25)/CGFloat(gameState.n + 1),
                    constant: 0.0)
            ]
        )
        
        view.bringSubviewToFront(progressVC!.view)
        
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
            self.plusLabel?.alpha = (challengeIndex > (self.gameState.challenges.count - self.gameState.n - 1)) ? 0.0 : 1.0
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
                progressVC?.view.transform = CGAffineTransformMakeTranslation(0.0, DesignLanguage.ProgressBarHeight)
                challengeContainer?.transform = CGAffineTransformMakeTranslation(view.bounds.size.width - (challengeContainer?.frame.origin.x ?? 0), 0.0)
                plusLabel?.transform = CGAffineTransformMakeTranslation(view.bounds.size.width - (plusLabel?.frame.origin.x ?? 0), 0.0)
                blurView?.alpha = 0
            case TransitionAnimationState.Active:
                progressVC?.view.transform = CGAffineTransformIdentity
                challengeContainer?.transform = CGAffineTransformIdentity
                plusLabel?.transform = CGAffineTransformIdentity
                blurView?.alpha = 1
        }
    }
    
    private let initialShakeDuration: NSTimeInterval = 0.1
    private let shakeReductionFactor: NSTimeInterval = 0.01
    private let totalNumShakes = 8
    private func shakeChallenges(shakeNumber: Int = 0) {
        UIView.animateWithDuration(initialShakeDuration - (NSTimeInterval(shakeNumber) * shakeReductionFactor), animations: {
            let sign: CGFloat = (shakeNumber%2 == 0) ? -1.0 : 1.0
            let initialShakeAmount = self.view.bounds.size.width/CGFloat(4*(self.gameState!.n + 1))
            let actualShakeAmount = initialShakeAmount - (initialShakeAmount*(CGFloat(shakeNumber)/CGFloat(self.totalNumShakes)))
            let translation = CGAffineTransformMakeTranslation(sign*actualShakeAmount, 0.0)
            self.challengeContainer?.transform = translation
            self.blurView?.blurredView.transform = translation
        }, completion: { (finished: Bool) -> Void in
            if (shakeNumber == self.totalNumShakes - 1) {
                self.challengeContainer?.transform = CGAffineTransformIdentity
                self.blurView?.blurredView.transform = CGAffineTransformIdentity
            } else {
                self.shakeChallenges(shakeNumber: shakeNumber + 1)
            }
        })
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
        gameState = change.newGameState
        if change.oldGameState?.currentChallengeIndex != change.newGameState?.currentChallengeIndex {
            if let newChallengeIndex = change.newGameState?.currentChallengeIndex {
                setActiveChallenge(newChallengeIndex, animated: true)
            }
        } else if change.oldGameState != nil && change.newGameState != nil {
            // Wrong answer was entered
            shakeChallenges()
        }
    }
}