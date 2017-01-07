//
//  GameplayOutputViewController.swift
//  recollect
//
//  Created by Vova Galchenko on 1/1/15.
//  Copyright (c) 2015 Vova Galchenko. All rights reserved.
//

import UIKit

class GameplayOutputViewController: HalfScreenViewController, UIGestureRecognizerDelegate {
    
    var gameState: GameState
    
    private var plusLabel: UILabel?
    private var progressVC: ProgressViewController?
    private var challengeContainer: UIView?
    private var blurView: BlurView?
    private var blurPanGestureRecognizer: UIPanGestureRecognizer?
    private var challengeContainerXPositionConstraint: NSLayoutConstraint?
    
    private let delegate: GameplayOutputViewControllerDelegate
    
    // Instructional Overlay
    fileprivate var borderOverlay: BorderView?
    
    init(gameState: GameState) {
        self.gameState = gameState
        self.delegate = GameManager.sharedInstance
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        progressVC = ProgressViewController()
        progressVC?.gameState = gameState
        addChildViewController(progressVC!)
        view.addSubview(progressVC!.view)
        progressVC!.didMove(toParentViewController: self)
        
        view.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "H:|[progressView]|",
                options: NSLayoutFormatOptions(rawValue: 0),
                metrics: nil,
                views: ["progressView" : progressVC!.view]) +
            NSLayoutConstraint.constraints(
                withVisualFormat: "V:[progressView(\(DesignLanguage.ProgressBarHeight))]|",
                options: NSLayoutFormatOptions(rawValue: 0),
                metrics: nil,
                views: ["progressView" : progressVC!.view])
        )
        
        challengeContainer = UIView()
        challengeContainer!.backgroundColor = UIColor.clear
        challengeContainer!.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(challengeContainer!)
        
        view.addConstraints(
            [
                NSLayoutConstraint(
                    item: challengeContainer!,
                    attribute: NSLayoutAttribute.top,
                    relatedBy: NSLayoutRelation.equal,
                    toItem: view,
                    attribute: NSLayoutAttribute.top,
                    multiplier: 1.0,
                    constant: 0.0),
                NSLayoutConstraint(
                    item: challengeContainer!,
                    attribute: NSLayoutAttribute.bottom,
                    relatedBy: NSLayoutRelation.equal,
                    toItem: progressVC!.view,
                    attribute: NSLayoutAttribute.top,
                    multiplier: 1.0,
                    constant: 0.0),
                NSLayoutConstraint(
                    item: challengeContainer!,
                    attribute: NSLayoutAttribute.width,
                    relatedBy: NSLayoutRelation.equal,
                    toItem: view,
                    attribute: NSLayoutAttribute.width,
                    multiplier: CGFloat(gameState.challenges.count)/CGFloat(gameState.n + 1),
                    constant: 0.0)
            ]
        )
        
        for (challengeIndex, challenge) in gameState.challenges.enumerated() {
            let topLabel = challengeLabel(challenge.lOperand)
            let bottomLabel = challengeLabel(challenge.rOperand)
            challengeContainer!.addSubview(topLabel)
            challengeContainer!.addSubview(bottomLabel)
            
            view.addConstraints(
                [
                    NSLayoutConstraint(
                        item: topLabel,
                        attribute: NSLayoutAttribute.centerY,
                        relatedBy: NSLayoutRelation.equal,
                        toItem: challengeContainer,
                        attribute: NSLayoutAttribute.centerY,
                        multiplier: 2.0/3.0,
                        constant: 0.0),
                    NSLayoutConstraint(
                        item: bottomLabel,
                        attribute: NSLayoutAttribute.centerY,
                        relatedBy: NSLayoutRelation.equal,
                        toItem: challengeContainer,
                        attribute: NSLayoutAttribute.centerY,
                        multiplier: 4.0/3.0,
                        constant: 0.0),
                    NSLayoutConstraint(
                        item: topLabel,
                        attribute: NSLayoutAttribute.centerX,
                        relatedBy: NSLayoutRelation.equal,
                        toItem: challengeContainer,
                        attribute: NSLayoutAttribute.centerX,
                        multiplier: (2.0/CGFloat(gameState.challenges.count * 2)) * CGFloat(challengeIndex*2 + 1),
                        constant: 0.0),
                    NSLayoutConstraint(
                        item: bottomLabel,
                        attribute: NSLayoutAttribute.centerX,
                        relatedBy: NSLayoutRelation.equal,
                        toItem: topLabel,
                        attribute: NSLayoutAttribute.centerX,
                        multiplier: 1.0,
                        constant: 0.0)
                ]
            )
        }
        
        blurView = BlurView(viewToBlur: challengeContainer!)
        blurView!.isUserInteractionEnabled = true
        blurPanGestureRecognizer = UIPanGestureRecognizer()
        blurPanGestureRecognizer!.delegate = self
        blurPanGestureRecognizer!.addTarget(self, action: #selector(GameplayOutputViewController.blurViewDragged(_:)))
        blurView!.addGestureRecognizer(blurPanGestureRecognizer!)
        view.addSubview(blurView!)
        
        view.addConstraints([
            NSLayoutConstraint(
                item: blurView!.blurredView,
                attribute: NSLayoutAttribute.centerY,
                relatedBy: NSLayoutRelation.equal,
                toItem: challengeContainer,
                attribute: NSLayoutAttribute.centerY,
                multiplier: 1.0,
                constant: 0.0),
            NSLayoutConstraint(
                item: blurView!.blurredView,
                attribute: NSLayoutAttribute.height,
                relatedBy: NSLayoutRelation.equal,
                toItem: challengeContainer,
                attribute: NSLayoutAttribute.height,
                multiplier:1.0,
                constant: 0.0),
            NSLayoutConstraint(
                item: blurView!.blurredView,
                attribute: NSLayoutAttribute.centerX,
                relatedBy: NSLayoutRelation.equal,
                toItem: challengeContainer,
                attribute: NSLayoutAttribute.centerX,
                multiplier: 1.0,
                constant: 0.0),
        ])
        
        view.addConstraints(
            [
                NSLayoutConstraint(
                    item: blurView!,
                    attribute: NSLayoutAttribute.top,
                    relatedBy: NSLayoutRelation.equal,
                    toItem: view,
                    attribute: NSLayoutAttribute.top,
                    multiplier: 1.0,
                    constant: 0.0),
                NSLayoutConstraint(
                    item: blurView!,
                    attribute: NSLayoutAttribute.bottom,
                    relatedBy: NSLayoutRelation.equal,
                    toItem: view,
                    attribute: NSLayoutAttribute.bottom,
                    multiplier: 1.0,
                    constant: 0.0),
                NSLayoutConstraint(
                    item: blurView!,
                    attribute: NSLayoutAttribute.left,
                    relatedBy: NSLayoutRelation.equal,
                    toItem: view,
                    attribute: NSLayoutAttribute.left,
                    multiplier: 1.0,
                    constant: 0.0),
                NSLayoutConstraint(
                    item: blurView!,
                    attribute: NSLayoutAttribute.right,
                    relatedBy: NSLayoutRelation.equal,
                    toItem: view,
                    attribute: NSLayoutAttribute.right,
                    multiplier: CGFloat(gameState.n)/CGFloat(gameState.n + 1),
                    constant: 0.0),
            ]
        )
        
        plusLabel = UILabel()
        plusLabel!.translatesAutoresizingMaskIntoConstraints = false
        plusLabel!.backgroundColor = UIColor.clear
        plusLabel!.textColor = DesignLanguage.NeverActiveTextColor
        plusLabel!.font = UIFont(name: "AvenirNext-Regular", size: 45.0)
        plusLabel!.text = "+"
        view.addSubview(plusLabel!)
        
        view.addConstraints(
            [
                NSLayoutConstraint(
                    item: plusLabel!,
                    attribute: NSLayoutAttribute.centerY,
                    relatedBy: NSLayoutRelation.equal,
                    toItem: challengeContainer,
                    attribute: NSLayoutAttribute.centerY,
                    multiplier: 1.0,
                    constant: 0.0),
                NSLayoutConstraint(
                    item: plusLabel!,
                    attribute: NSLayoutAttribute.centerX,
                    relatedBy: NSLayoutRelation.equal,
                    toItem: view,
                    attribute: NSLayoutAttribute.right,
                    multiplier: (CGFloat(gameState.n) + 0.25)/CGFloat(gameState.n + 1),
                    constant: 0.0)
            ]
        )
        
        view.bringSubview(toFront: progressVC!.view)
        
        setActiveChallenge(gameState.currentChallengeIndex, animated: false)
        
        GameManager.sharedInstance.subscribeToGameStateChangeNotifications(self)
    }
    
    deinit {
        GameManager.sharedInstance.unsubscribeFromGameStateChangeNotifications(self)
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        // Don't do anything if we don't have anything under the blur view
        return gameState.currentChallengeIndex > -gameState.n
    }
    
    var previousXTranslation: CGFloat = 0.0
    func blurViewDragged(_ panGestureRecognizer: UIPanGestureRecognizer) {
        if panGestureRecognizer.state == UIGestureRecognizerState.began ||
           panGestureRecognizer.state == UIGestureRecognizerState.changed {
            if panGestureRecognizer.state == UIGestureRecognizerState.began {
                currentSlidingHighlightId = nil
                blurView!.layer.removeAllAnimations()
            }
            let xTranslation: CGFloat = panGestureRecognizer.translation(in: self.view).x
            if xTranslation <= 0 {
                blurView!.transform = CGAffineTransform(translationX: xTranslation, y: 0.0)
                blurView!.blurredView.transform = CGAffineTransform(translationX: -xTranslation, y: 0.0)
            }
            
            var labelXCenters = [CGFloat]()
            let increment = blurView!.bounds.width/CGFloat(gameState.n)
            var curr = -increment/2
            while curr > -blurView!.bounds.width {
                labelXCenters.append(curr)
                curr -= increment
            }
            
            var labelWidth: CGFloat = 0
            for subview in challengeContainer!.subviews {
                if let label = subview as? ManglableLabel {
                    if Int(label.text ?? "") != nil {
                        labelWidth = label.bounds.width
                        break
                    }
                }
            }
            
            let numLabelsUnderBlur = gameState.n + min(gameState.currentChallengeIndex, 0)
            let labelEdges = Array(labelXCenters[0..<numLabelsUnderBlur].map { $0 + labelWidth/2 })
            
            for labelEdge in labelEdges {
                if previousXTranslation >= labelEdge && xTranslation < labelEdge {
                    delegate.peeked()
                }
            }
            
            previousXTranslation = xTranslation
        } else if panGestureRecognizer.state == UIGestureRecognizerState.ended ||
                  panGestureRecognizer.state == UIGestureRecognizerState.cancelled {
            let priorXTranslate = self.blurView!.transform.tx
            UIView.animate(
                withDuration: DesignLanguage.MinorAnimationDuration/2.0,
                delay: 0.0,
                options: UIViewAnimationOptions.curveEaseIn,
                animations: { () -> Void in
                    self.blurView!.transform = CGAffineTransform.identity
                    self.blurView!.blurredView.transform = CGAffineTransform.identity
                }) { (finished: Bool) -> Void in
                UIView.animate(
                    withDuration: DesignLanguage.MinorAnimationDuration/3.0,
                    delay: 0.0,
                    options: UIViewAnimationOptions.curveEaseOut,
                    animations: { () -> Void in
                        self.blurView!.transform = CGAffineTransform(translationX: priorXTranslate/CGFloat(8.0), y: 0.0)
                        self.blurView!.blurredView.transform = CGAffineTransform(translationX: -priorXTranslate/CGFloat(8.0), y: 0.0)
                }) { (finished: Bool) -> Void in
                    UIView.animate(
                        withDuration: DesignLanguage.MinorAnimationDuration/3.0,
                        delay: 0.0,
                        options: UIViewAnimationOptions.curveEaseIn,
                        animations: { () -> Void in
                            self.blurView!.transform = CGAffineTransform.identity
                            self.blurView!.blurredView.transform = CGAffineTransform.identity
                    }, completion: nil)
                }
            }
        }
    }
    
    func challengeLabel(_ operand: Int) -> ManglableLabel {
        let label = ManglableLabel()
        label.backgroundColor = UIColor.clear
        label.textColor = DesignLanguage.NeverActiveTextColor
        label.font = UIFont(name: "AvenirNext-Regular", size: 76.0)
        label.text = "\(operand)"
        return label
    }
    
    func setActiveChallenge(_ challengeIndex: Int, animated: Bool) {
        view.layoutIfNeeded()
        setupChallengeContainerXPositionConstraint(challengeIndex)
        UIView.animate(withDuration: animated ? DesignLanguage.MinorAnimationDuration : 0.0, animations: { () -> Void in
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
            self.plusLabel?.alpha = (challengeIndex > (self.gameState.challenges.count - self.gameState.n - 1)) ? 0.0 : 1.0
        })
    }
    
    private func setupChallengeContainerXPositionConstraint(_ challengeIndex: Int) {
        if let constraintToRemove = challengeContainerXPositionConstraint {
            view.removeConstraint(constraintToRemove)
        }
        challengeContainerXPositionConstraint = NSLayoutConstraint(
            item: challengeContainer!,
            attribute: NSLayoutAttribute.left,
            relatedBy: NSLayoutRelation.equal,
            toItem: view,
            attribute: NSLayoutAttribute.right,
            multiplier: UIView.sanitizeLocationConstraintMultiplier(-CGFloat(challengeIndex)/CGFloat(gameState.n + 1)),
            constant: 0.0)
        view.addConstraint(challengeContainerXPositionConstraint!)
    }
    
    private func configureForTransition(_ animationState: TransitionAnimationState) {
        switch animationState {
            case TransitionAnimationState.inactive:
                progressVC?.view.transform = CGAffineTransform(translationX: 0.0, y: DesignLanguage.ProgressBarHeight)
                let challengesTransform = CGAffineTransform(translationX: view.bounds.size.width - (challengeContainer?.frame.origin.x ?? 0), y: 0.0)
                challengeContainer?.transform = challengesTransform
                plusLabel?.transform = CGAffineTransform(translationX: view.bounds.size.width - (plusLabel?.frame.origin.x ?? 0), y: 0.0)
                blurView?.blurredView.transform = challengesTransform
                blurView?.alpha = 0
            case TransitionAnimationState.active:
                progressVC?.view.transform = CGAffineTransform.identity
                challengeContainer?.transform = CGAffineTransform.identity
                blurView?.blurredView.transform = CGAffineTransform.identity
                challengeContainer?.alpha = 1
                plusLabel?.transform = CGAffineTransform.identity
                blurView?.alpha = 1
        }
    }
    
    private let initialShakeDuration: Foundation.TimeInterval = 0.1
    private let shakeReductionFactor: Foundation.TimeInterval = 0.01
    private let totalNumShakes = 8
    fileprivate func shakeChallenges(_ slideHighlightId: UUID, shakeNumber: Int = 0) {
        UIView.animate(withDuration: initialShakeDuration - (Foundation.TimeInterval(shakeNumber) * shakeReductionFactor), animations: {
            let sign: CGFloat = (shakeNumber%2 == 0) ? -1.0 : 1.0
            let initialShakeAmount = self.view.bounds.size.width/CGFloat(4*(self.gameState.n + 1))
            let actualShakeAmount = initialShakeAmount - (initialShakeAmount*(CGFloat(shakeNumber)/CGFloat(self.totalNumShakes)))
            let translation = CGAffineTransform(translationX: sign*actualShakeAmount, y: 0.0)
            self.challengeContainer?.transform = translation
            self.blurView?.blurredView.transform = translation
            self.borderOverlay?.transform = translation
        }, completion: { (finished: Bool) -> Void in
            if (shakeNumber == self.totalNumShakes - 1) && finished {
                self.challengeContainer?.transform = CGAffineTransform.identity
                self.blurView?.blurredView.transform = CGAffineTransform.identity
                self.borderOverlay?.transform = CGAffineTransform.identity
                let dispatchTime = DispatchTime.now() + Double(Int64(1.0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
                self.currentSlidingHighlightId = ((slideHighlightId as NSUUID).copy() as! UUID)
                DispatchQueue.main.asyncAfter(deadline: dispatchTime) {
                    self.highlightSlidingIfNeeded(slideHighlightId)
                }
                
            } else if finished {
                self.shakeChallenges(slideHighlightId, shakeNumber: shakeNumber + 1)
            }
        })
    }
    
    fileprivate var currentSlidingHighlightId: UUID? = nil
    private func highlightSlidingIfNeeded(_ highlightId: UUID) {
        if highlightId == currentSlidingHighlightId {
            let slidingAmount: CGFloat = 20
            UIView.animate(
                withDuration: DesignLanguage.MinorAnimationDuration/2.0,
                delay: 0.0,
                options: UIViewAnimationOptions.curveEaseOut,
                animations: { () -> Void in
                    self.blurView!.transform = CGAffineTransform(translationX: -slidingAmount, y: 0.0)
                    self.blurView!.blurredView.transform = CGAffineTransform(translationX: slidingAmount, y: 0.0)
                }) { (finished: Bool) -> Void in
                    if !finished { return }
                    UIView.animate(
                        withDuration: DesignLanguage.MinorAnimationDuration/2.0,
                        delay: 0.0,
                        options: UIViewAnimationOptions.curveEaseIn,
                        animations: { () -> Void in
                            self.blurView!.transform = CGAffineTransform.identity
                            self.blurView!.blurredView.transform = CGAffineTransform.identity
                        }) { (finished: Bool) -> Void in
                            if !finished { return }
                            UIView.animate(
                                withDuration: DesignLanguage.MinorAnimationDuration/3.0,
                                delay: 0.0,
                                options: UIViewAnimationOptions.curveEaseOut,
                                animations: { () -> Void in
                                    self.blurView!.transform = CGAffineTransform(translationX: -slidingAmount/8.0, y: 0.0)
                                    self.blurView!.blurredView.transform = CGAffineTransform(translationX: slidingAmount/8.0, y: 0.0)
                                }) { (finished: Bool) -> Void in
                                if !finished { return }
                                UIView.animate(
                                    withDuration: DesignLanguage.MinorAnimationDuration/3.0,
                                    delay: 0.0,
                                    options: UIViewAnimationOptions.curveEaseIn,
                                    animations: { () -> Void in
                                        self.blurView!.transform = CGAffineTransform.identity
                                        self.blurView!.blurredView.transform = CGAffineTransform.identity
                                    }) { (finished: Bool) -> Void in
                                    let dispatchTime = DispatchTime.now() + Double(Int64(3.0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
                                    DispatchQueue.main.asyncAfter(deadline: dispatchTime) {
                                        self.highlightSlidingIfNeeded(highlightId)
                                    }
                                }
                            }
                    }
            }
        }
    }
    
    func presentInstructionalOverlayIfNeeded(_ timer: Timer) {
        let gameStateAtTimerSetup = timer.userInfo as! GameState
        
        if gameStateAtTimerSetup.currentChallengeIndex == gameState.currentChallengeIndex && challengeContainer != nil {
            var minYOrigin = CGFloat.greatestFiniteMagnitude
            var maxBottom = CGFloat.leastNormalMagnitude
            var maxWidth = CGFloat.leastNormalMagnitude
            for subview in challengeContainer!.subviews {
                if subview.frame.origin.y < minYOrigin {
                    minYOrigin = subview.frame.origin.y
                }
                if subview.frame.origin.y + subview.bounds.height > maxBottom {
                    maxBottom = subview.frame.origin.y + subview.bounds.height
                }
                if subview.bounds.width > maxWidth {
                    maxWidth = subview.bounds.width
                }
            }
            
            if borderOverlay == nil {
                borderOverlay = BorderView()
                borderOverlay!.alpha = 0.0
                blurView?.addSubview(borderOverlay!)
            }
            let blurPadding: CGFloat = 10
            view.addConstraints([
                NSLayoutConstraint(
                    item: borderOverlay!,
                    attribute: NSLayoutAttribute.centerX,
                    relatedBy: NSLayoutRelation.equal,
                    toItem: blurView,
                    attribute: NSLayoutAttribute.right,
                    multiplier: 1.0/CGFloat(2*gameState.n),
                    constant: 0.0),
                NSLayoutConstraint(
                    item: borderOverlay!,
                    attribute: NSLayoutAttribute.centerY,
                    relatedBy: NSLayoutRelation.equal,
                    toItem: challengeContainer!,
                    attribute: NSLayoutAttribute.centerY,
                    multiplier: 1.0,
                    constant: 0.0),
                NSLayoutConstraint(
                    item: borderOverlay!,
                    attribute: NSLayoutAttribute.width,
                    relatedBy: NSLayoutRelation.equal,
                    toItem: nil,
                    attribute: NSLayoutAttribute.notAnAttribute,
                    multiplier: 0.0,
                    constant: maxWidth + blurPadding),
                NSLayoutConstraint(
                    item: borderOverlay!,
                    attribute: NSLayoutAttribute.height,
                    relatedBy: NSLayoutRelation.equal,
                    toItem: nil,
                    attribute: NSLayoutAttribute.notAnAttribute,
                    multiplier: 0.0,
                    constant: maxBottom - minYOrigin)
            ])
            
            UIView.animate(withDuration: DesignLanguage.MinorAnimationDuration, animations: {
                self.borderOverlay!.alpha = 1.0
            }) 
        }
    }
    
    override func animationWillBegin(_ beginningState: TransitionAnimationState, plannedAnimationDuration: Foundation.TimeInterval) {
        super.animationWillBegin(beginningState, plannedAnimationDuration: plannedAnimationDuration)
        view.superview?.bringSubview(toFront: view)
        configureForTransition(beginningState)
        
        if beginningState == TransitionAnimationState.active {
            challengeContainer?.layer.removeAllAnimations()
        }
    }
    
    override func addToAnimationBlock(_ endingState: TransitionAnimationState) {
        configureForTransition(endingState)
    }
    
    override func managesOwnTransitions() -> Bool {
        return true
    }
}

extension GameplayOutputViewController: GameStateChangeListener {
    func gameStateChanged(_ change: GameStateChange) {
        if let newGameState = change.newGameState {
            gameState = newGameState
            if change.oldGameState?.currentChallengeIndex != newGameState.currentChallengeIndex {
                if newGameState.currentChallengeIndex < newGameState.challenges.count {
                    currentSlidingHighlightId = nil
                    setActiveChallenge(newGameState.currentChallengeIndex, animated: true)
                }
            } else if change.oldGameState != nil &&
                change.oldGameState!.currentChallenge()?.userResponses.count == ((newGameState.currentChallenge()?.userResponses.count ?? 0) - 1) {
                // Wrong answer was entered
                shakeChallenges(UUID())
            }
            
            if gameState.currentChallengeIndex >= 0 && gameState.currentChallengeIndex < gameState.challenges.count
                && gameState.currentChallengeIndex - 1 == change.oldGameState?.currentChallengeIndex {
                    if borderOverlay?.superview != nil {
                        UIView.animate(withDuration: DesignLanguage.MinorAnimationDuration, animations: {
                            self.borderOverlay!.alpha = 0.0
                        })
                    }
                    PlayerIdentityManager.sharedInstance.currentIdentity.getMyBestScores { bestScores in
                        Timer.scheduledTimer(
                            timeInterval: DesignLanguage.delayBeforeInstructionalOverlay(self.gameState.levelId, finishedLevelBefore: bestScores[self.gameState.levelId] != nil),
                            target: self,
                            selector: #selector(GameplayOutputViewController.presentInstructionalOverlayIfNeeded(_:)),
                            userInfo: self.gameState,
                            repeats: false)
                    }
                    
            }
        }
    }
}

protocol GameplayOutputViewControllerDelegate {
    func peeked()
}
