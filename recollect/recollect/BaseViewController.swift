//
//  ViewController.swift
//  recollect
//
//  Created by Vova Galchenko on 10/19/14.
//  Copyright (c) 2014 Vova Galchenko. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {
    
    let transitionWidthDelta: CGFloat = 50
    let transitionStartScale: CGFloat = 0.75
    let transitionEndScale: CGFloat = 1.25
    var topViewController: HalfScreenViewController?
    var bottomViewController: HalfScreenViewController?
    
    var topHalfContainerView: UIView?
    var bottomHalfContainerView: UIView?
    
    var continueHelperOverlay: ContinueInstructionOverlayView?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = DesignLanguage.TopHalfBGColor
        bottomHalfContainerView = UIView()
        bottomHalfContainerView!.clipsToBounds = true
        bottomHalfContainerView!.backgroundColor = DesignLanguage.BottomHalfBGColor
        bottomHalfContainerView!.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bottomHalfContainerView!)
        
        topHalfContainerView = UIView()
        topHalfContainerView!.clipsToBounds = true
        topHalfContainerView!.backgroundColor = DesignLanguage.TopHalfBGColor
        topHalfContainerView!.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(topHalfContainerView!)
        
        view.addConstraints(constraints(topHalfContainerView!, isTop: true) + constraints(bottomHalfContainerView!, isTop: false))
        
        queueTransition(
            newTopViewControllerFunc: { return LogoViewController() },
            newBottomViewControllerFunc: { return LevelPickerViewController(delegate: GameManager.sharedInstance) },
            rotationParams: (.none, .none)
        )
        
        GameManager.sharedInstance.subscribeToGameStateChangeNotifications(self)
    }
    
    private func constraints(_ halfViewContainer: UIView, isTop: Bool) -> [NSLayoutConstraint] {
        return [
            NSLayoutConstraint(item: halfViewContainer,
                attribute: NSLayoutAttribute.centerX,
                relatedBy: NSLayoutRelation.equal,
                toItem: self.view!,
                attribute: NSLayoutAttribute.centerX,
                multiplier: 1.0,
                constant: 0.0),
            NSLayoutConstraint(item: halfViewContainer,
                attribute: NSLayoutAttribute.centerY,
                relatedBy: NSLayoutRelation.equal,
                toItem: self.view!,
                attribute: NSLayoutAttribute.centerY,
                multiplier: isTop ? 0.5 : 1.5,
                constant: 0.0),
            NSLayoutConstraint(item: halfViewContainer,
                attribute: NSLayoutAttribute.width,
                relatedBy: NSLayoutRelation.equal,
                toItem: self.view!,
                attribute: NSLayoutAttribute.width,
                multiplier: 1.0,
                constant: 0.0),
            NSLayoutConstraint(item: halfViewContainer,
                attribute: NSLayoutAttribute.height,
                relatedBy: NSLayoutRelation.equal,
                toItem: self.view!,
                attribute: NSLayoutAttribute.height,
                multiplier: 0.5,
                constant: 0.0)
        ]
    }
    
    deinit {
        GameManager.sharedInstance.unsubscribeFromGameStateChangeNotifications(self)
    }
    
    // Ewwww, I really should turn these into objects
    private var transitionQueue: [((() -> HalfScreenViewController?)?, (() -> HalfScreenViewController?)?, HalfScreenViewController?, HalfScreenViewController?, (TransitionRotation, TransitionRotation))] = []
    
    func queueTransition(newTopViewControllerFunc: (() -> HalfScreenViewController?)? = nil, newBottomViewControllerFunc: (() -> HalfScreenViewController?)? = nil,
        checkTopViewController: HalfScreenViewController? = nil, checkBottomViewController: HalfScreenViewController? = nil, rotationParams: (TransitionRotation, TransitionRotation)) {
        assert(Thread.isMainThread, "queueTransition(...) has to be called on the main thread")
        transitionQueue.append((newTopViewControllerFunc, newBottomViewControllerFunc, checkTopViewController, checkBottomViewController, rotationParams))
        if transitionQueue.count == 1 {
            transition()
        }
    }
    
    private func transition() {
        assert(Thread.isMainThread, "transition(...) has to be called on the main thread")
        
        if (transitionQueue.count == 0) { return }
        let (newTopViewControllerFunc, newBottomViewControllerFunc, checkTopViewController, checkBottomViewController, rotationParams) = transitionQueue[0]
        
        
        let newTopViewController = newTopViewControllerFunc == nil ? self.topViewController : newTopViewControllerFunc!()
        let newBottomViewController = newBottomViewControllerFunc == nil ? self.bottomViewController : newBottomViewControllerFunc!()
        if (checkBottomViewController != nil && checkBottomViewController != self.bottomViewController) ||
           (checkTopViewController != nil && checkTopViewController != self.topViewController) {
            transitionQueue.remove(at: 0)
            transition()
            return
        }
                                
        let controllersToAnimate = [
            getControllersToAnimate(oldController: topViewController, newController: newTopViewController),
            getControllersToAnimate(oldController: bottomViewController, newController: newBottomViewController)
        ]
        
        let constraint: NSLayoutConstraint? = nil
        
        var newViewConstraints = [NSLayoutConstraint]()
        var constraintsToRemove = [NSLayoutConstraint]()
        for (oldController, newController) in controllersToAnimate {
            if let existingNewController = newController {
                existingNewController.view.alpha = existingNewController.managesOwnTransitions() ? 1.0 : 0.0
                
                self.addChildViewController(existingNewController)
                let isTop = existingNewController == newTopViewController
                let viewToAddTo = isTop ? self.topHalfContainerView! : self.bottomHalfContainerView!
                viewToAddTo.addSubview(existingNewController.view)
                viewToAddTo.sendSubview(toBack: existingNewController.view)
                existingNewController.didMove(toParentViewController: self)
                
                newViewConstraints.append(
                    contentsOf: NSLayoutConstraint.constraints(
                        withVisualFormat: "V:|[newView]|",
                        options: NSLayoutFormatOptions(rawValue: 0),
                        metrics: nil,
                        views: ["newView" : existingNewController.view]) +
                        NSLayoutConstraint.constraints(
                            withVisualFormat: "H:|[newView]|",
                            options: NSLayoutFormatOptions(rawValue: 0),
                            metrics: nil,
                            views: ["newView" : existingNewController.view])
                )
                
                if !existingNewController.managesOwnTransitions() {
                    let sign = CGFloat(isTop ? rotationParams.0.rawValue : rotationParams.1.rawValue)
                    existingNewController.view.transform = CGAffineTransform(scaleX: transitionStartScale, y: transitionStartScale).rotated(by: sign * CGFloat(M_PI_2))
                }
                existingNewController.animationWillBegin(.inactive, plannedAnimationDuration: DesignLanguage.TransitionAnimationDuration)
            }
            if let existingOldController = oldController {
                constraintsToRemove.append(contentsOf: existingOldController.view.superview?.constraintsConstrainingView(existingOldController.view) ?? [NSLayoutConstraint]())
                existingOldController.animationWillBegin(.active, plannedAnimationDuration: DesignLanguage.TransitionAnimationDuration)
            }
        }
        view.addConstraints(newViewConstraints)
        view.setNeedsLayout()
        view.layoutIfNeeded()
        

        let animatingOutViews = controllersToAnimate.map { $0.0?.view }.filter { $0 != nil }.map { $0! }
        UIView.animate(withDuration: DesignLanguage.TransitionAnimationDuration, animations: {
            for (oldController, newController) in controllersToAnimate {
                if let existingOldController = oldController {
                    existingOldController.addToAnimationBlock(.inactive)
                    if !existingOldController.managesOwnTransitions() {
                        existingOldController.view.alpha = 0
                        let isTop = existingOldController.view.superview == self.topHalfContainerView
                        let sign = -CGFloat(isTop ? rotationParams.0.rawValue : rotationParams.1.rawValue)
                        existingOldController.view.transform = CGAffineTransform(scaleX: self.transitionEndScale, y: self.transitionEndScale).rotated(by: sign * CGFloat(M_PI_2))
                    }
                }
                if let existingNewController = newController {
                    existingNewController.addToAnimationBlock(.active)
                    if !existingNewController.managesOwnTransitions() {
                        existingNewController.view.alpha = 1.0
                        existingNewController.view.transform = CGAffineTransform.identity
                    }
                }
            }
        }, completion: { (finished: Bool) in
            assert(Thread.isMainThread, "Expecting the animation completion to be executed on the main thread")
            for (oldController, _) in controllersToAnimate {
                if let existingOldController = oldController {
                    existingOldController.willMove(toParentViewController: nil)
                    let superviewHalf = existingOldController.view.superview
                    existingOldController.view.removeFromSuperview()
                    existingOldController.removeFromParentViewController()
                    superviewHalf?.removeConstraints(constraintsToRemove)
                }
            }
            
            self.transitionQueue.remove(at: 0)
            self.transition()
        }) 
        
        self.topViewController = newTopViewController
        self.bottomViewController = newBottomViewController
        
        func doAfterRandomTimeout(_ work: @escaping () -> Void) {
            let minTimeout = 5.0 + DesignLanguage.TransitionAnimationDuration
            let maxTimeout = minTimeout + 25.0
            let timeout = (Double(arc4random()) / Double(UINT32_MAX))*(maxTimeout - minTimeout) + minTimeout
            let dispatchTime = DispatchTime.now() + Double(Int64(timeout * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: dispatchTime, execute: work)
        }
        
        func randomRotationParam() -> TransitionRotation { return TransitionRotation(rawValue: (Int(arc4random()) % 3) - 1)! }
        
        if topViewController?.isPurelyDecorative() ?? false {
            let requiredOldVc = topViewController
            doAfterRandomTimeout {
                self.queueTransition(
                    newTopViewControllerFunc: newTopViewControllerFunc,
                    checkTopViewController: requiredOldVc,
                    rotationParams: (randomRotationParam(), .none)
                )
            }
        }
        if bottomViewController?.isPurelyDecorative() ?? false {
            let requiredOldVc = bottomViewController
            doAfterRandomTimeout {
                self.queueTransition(
                    newBottomViewControllerFunc: newBottomViewControllerFunc,
                    checkBottomViewController: requiredOldVc,
                    rotationParams: (.none, randomRotationParam())
                )
            }
        }
    }
    
    private func getControllersToAnimate(oldController: HalfScreenViewController?, newController: HalfScreenViewController?) -> (HalfScreenViewController?, HalfScreenViewController?) {
        if oldController != nil && oldController! == newController {
            // The two controllers are the same – nothing to animate
            return (nil, nil);
        } else {
            return (oldController, newController);
        }
    }
    
    func showContinueInstructionOverlayIfNeeded(_ timer: Timer) {
        let gameState = timer.userInfo! as! GameState
        if GameManager.sharedInstance.currentGameState == gameState && continueHelperOverlay == nil {
            continueHelperOverlay = ContinueInstructionOverlayView()
            continueHelperOverlay!.alpha = 0
            bottomHalfContainerView?.addSubview(continueHelperOverlay!)
            bottomHalfContainerView?.addConstraints(
                NSLayoutConstraint.constraints(
                    withVisualFormat: "H:|[overlay]|",
                    options: NSLayoutFormatOptions(rawValue: 0),
                    metrics: nil,
                    views: ["overlay" : continueHelperOverlay!]) +
                NSLayoutConstraint.constraints(
                    withVisualFormat: "V:|[overlay]|",
                    options: NSLayoutFormatOptions(rawValue: 0),
                    metrics: nil,
                    views: ["overlay" : continueHelperOverlay!])
            )
            
            UIView.animate(withDuration: DesignLanguage.MinorAnimationDuration, animations: {
                self.continueHelperOverlay!.alpha = 1
            }) 
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
}


extension BaseViewController: GameStateChangeListener {
    func gameStateChanged(_ change: GameStateChange) {
        if change.newGameState != nil && (change.oldGameState?.gameId ?? "") != change.newGameState!.gameId {
            queueTransition(
                newTopViewControllerFunc: { return GameplayOutputViewController(gameState: change.newGameState!) },
                newBottomViewControllerFunc: { return GameplayInputController(delegate: GameManager.sharedInstance) },
                rotationParams: (.none, change.oldGameState == nil ? .clockwise : .anticlockwise)
            )
        } else if change.oldGameState != nil && change.newGameState == nil {
            queueTransition(
                newTopViewControllerFunc: { return LogoViewController() },
                newBottomViewControllerFunc: { return LevelPickerViewController(delegate: GameManager.sharedInstance) },
                rotationParams: (.none, self.bottomViewController is GameplayInputController ? .anticlockwise : .none)
            )
        } else if change.newGameState?.isFinished() ?? false {
            queueTransition(
                newTopViewControllerFunc: { return GameResultViewController(gameState: change.newGameState!) },
                newBottomViewControllerFunc: { return SharingViewController(gameState: change.newGameState!) },
                rotationParams: (.none, .clockwise)
            )
        }
        
        if continueHelperOverlay?.superview != nil {
            UIView.animate(
                withDuration: DesignLanguage.MinorAnimationDuration,
                animations: { () -> Void in
                    self.continueHelperOverlay!.alpha = 0.0
                }, completion: { (finished: Bool) -> Void in
                    self.bottomHalfContainerView!.removeConstraints(self.bottomHalfContainerView!.constraintsConstrainingView(self.continueHelperOverlay!))
                    self.continueHelperOverlay!.removeFromSuperview()
                    self.continueHelperOverlay = nil
            }) 
        }
        
        if (change.newGameState?.currentChallengeIndex ?? 0) < 0 {
            PlayerIdentityManager.sharedInstance.currentIdentity.getMyBestScores { bestScores in
                Timer.scheduledTimer(
                    timeInterval: DesignLanguage.delayBeforeInstructionalOverlay(change.newGameState!.levelId, finishedLevelBefore: bestScores[change.newGameState!.levelId] != nil),
                    target: self,
                    selector: #selector(BaseViewController.showContinueInstructionOverlayIfNeeded(_:)),
                    userInfo: change.newGameState!,
                    repeats: false)
            }
        }
    }
}

extension UIView {
    func constraintsConstrainingView(
        _ constrainedView: UIView,
        constrainedAttributePredicate: ((NSLayoutAttribute) -> Bool) = { _ -> Bool in return true }
    ) -> [NSLayoutConstraint] {
        return constraints.filter {
            ($0.firstItem as! NSObject == constrainedView && constrainedAttributePredicate($0.firstAttribute)) ||
            ($0.secondItem as! NSObject == constrainedView && constrainedAttributePredicate($0.secondAttribute))
        }
    }
}

enum TransitionRotation: Int {
    case clockwise = -1
    case none
    case anticlockwise
}

enum TransitionAnimationState {
    case inactive
    case active
}

protocol TransitionAnimationDelegate {
    func animationWillBegin(_ beginningState: TransitionAnimationState, plannedAnimationDuration: Foundation.TimeInterval)
    func addToAnimationBlock(_ endingState: TransitionAnimationState)
    func managesOwnTransitions() -> Bool
    func isPurelyDecorative() -> Bool
}
