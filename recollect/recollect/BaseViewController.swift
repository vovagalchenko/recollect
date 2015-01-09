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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = DesignLanguage.TopHalfBGColor
        bottomHalfContainerView = UIView()
        bottomHalfContainerView!.clipsToBounds = true
        bottomHalfContainerView!.backgroundColor = DesignLanguage.BottomHalfBGColor
        bottomHalfContainerView!.setTranslatesAutoresizingMaskIntoConstraints(false)
        view.addSubview(bottomHalfContainerView!)
        
        topHalfContainerView = UIView()
        topHalfContainerView!.clipsToBounds = true
        topHalfContainerView!.backgroundColor = DesignLanguage.TopHalfBGColor
        topHalfContainerView!.setTranslatesAutoresizingMaskIntoConstraints(false)
        view.addSubview(topHalfContainerView!)
        
        view.addConstraints(constraints(topHalfContainerView!, isTop: true) + constraints(bottomHalfContainerView!, isTop: false))
        
        queueTransition(
            newTopViewControllerFunc: { return LogoViewController() },
            newBottomViewControllerFunc: { return LevelPickerViewController(delegate: GameManager.sharedInstance) }
        )
        
        GameManager.sharedInstance.subscribeToGameStateChangeNotifications(self)
    }
    
    private func constraints(halfViewContainer: UIView, isTop: Bool) -> [AnyObject] {
        return [
            NSLayoutConstraint(item: halfViewContainer,
                attribute: NSLayoutAttribute.CenterX,
                relatedBy: NSLayoutRelation.Equal,
                toItem: self.view!,
                attribute: NSLayoutAttribute.CenterX,
                multiplier: 1.0,
                constant: 0.0),
            NSLayoutConstraint(item: halfViewContainer,
                attribute: NSLayoutAttribute.CenterY,
                relatedBy: NSLayoutRelation.Equal,
                toItem: self.view!,
                attribute: NSLayoutAttribute.CenterY,
                multiplier: isTop ? 0.5 : 1.5,
                constant: 0.0),
            NSLayoutConstraint(item: halfViewContainer,
                attribute: NSLayoutAttribute.Width,
                relatedBy: NSLayoutRelation.Equal,
                toItem: self.view!,
                attribute: NSLayoutAttribute.Width,
                multiplier: 1.0,
                constant: 0.0),
            NSLayoutConstraint(item: halfViewContainer,
                attribute: NSLayoutAttribute.Height,
                relatedBy: NSLayoutRelation.Equal,
                toItem: self.view!,
                attribute: NSLayoutAttribute.Height,
                multiplier: 0.5,
                constant: 0.0)
        ]
    }
    
    deinit {
        GameManager.sharedInstance.unsubscribeFromGameStateChangeNotifications(self)
    }
    
    private var transitionQueue: [((() -> HalfScreenViewController?)?, (() -> HalfScreenViewController?)?, HalfScreenViewController?, HalfScreenViewController?)] = Array()
    
    func queueTransition(newTopViewControllerFunc: (() -> HalfScreenViewController?)? = nil, newBottomViewControllerFunc: (() -> HalfScreenViewController?)? = nil,
        checkTopViewController: HalfScreenViewController? = nil, checkBottomViewController: HalfScreenViewController? = nil) {
        assert(NSThread.isMainThread(), "queueTransition(...) has to be called on the main thread")
        transitionQueue.append((newTopViewControllerFunc, newBottomViewControllerFunc, checkTopViewController, checkBottomViewController))
        if transitionQueue.count == 1 {
            transition()
        }
    }
    
    private func transition() {
        assert(NSThread.isMainThread(), "transition(...) has to be called on the main thread")
        
        if (transitionQueue.count == 0) { return }
        let (newTopViewControllerFunc, newBottomViewControllerFunc, checkTopViewController, checkBottomViewController) = transitionQueue[0]
        
        
        let newTopViewController = newTopViewControllerFunc == nil ? self.topViewController : newTopViewControllerFunc!()
        let newBottomViewController = newBottomViewControllerFunc == nil ? self.bottomViewController : newBottomViewControllerFunc!()
        if (checkBottomViewController != nil && checkBottomViewController != self.bottomViewController) ||
           (checkTopViewController != nil && checkTopViewController != self.topViewController) {
            transitionQueue.removeAtIndex(0)
            transition()
            return
        }
                                
        let controllersToAnimate = [
            getControllersToAnimate(oldController: topViewController, newController: newTopViewController),
            getControllersToAnimate(oldController: bottomViewController, newController: newBottomViewController)
        ]
        
        let constraint: NSLayoutConstraint? = nil
        
        var newViewConstraints: [AnyObject] = [NSLayoutConstraint]()
        var constraintsToRemove: [AnyObject] = [NSLayoutConstraint]()
        for (oldController, newController) in controllersToAnimate {
            if let existingNewController = newController {
                existingNewController.view.alpha = existingNewController.managesOwnTransitions() ? 1.0 : 0.0
                
                self.addChildViewController(existingNewController)
                let isTop = existingNewController == newTopViewController
                let viewToAddTo = isTop ? self.topHalfContainerView! : self.bottomHalfContainerView!
                viewToAddTo.addSubview(existingNewController.view)
                viewToAddTo.sendSubviewToBack(existingNewController.view)
                existingNewController.didMoveToParentViewController(self)
                
                newViewConstraints.extend(
                    NSLayoutConstraint.constraintsWithVisualFormat(
                        "V:|[newView]|",
                        options: NSLayoutFormatOptions(0),
                        metrics: nil,
                        views: ["newView" : existingNewController.view]) +
                        NSLayoutConstraint.constraintsWithVisualFormat(
                            "H:|[newView]|",
                            options: NSLayoutFormatOptions(0),
                            metrics: nil,
                            views: ["newView" : existingNewController.view])
                )
                
                if !existingNewController.managesOwnTransitions() {
                    existingNewController.view.transform = CGAffineTransformMakeScale(transitionStartScale, transitionStartScale)
                }
                existingNewController.animationWillBegin(.Inactive, plannedAnimationDuration: DesignLanguage.TransitionAnimationDuration)
            }
            if let existingOldController = oldController {
                constraintsToRemove.extend(existingOldController.view.superview?.constraints() ?? [])
                existingOldController.animationWillBegin(.Active, plannedAnimationDuration: DesignLanguage.TransitionAnimationDuration)
            }
        }
        view.addConstraints(newViewConstraints)
        view.setNeedsLayout()
        view.layoutIfNeeded()
        

        let animatingOutViews = controllersToAnimate.map { $0.0?.view }.filter { $0 != nil }.map { $0! }
        UIView.animateWithDuration(DesignLanguage.TransitionAnimationDuration, animations: {
            for (oldController, newController) in controllersToAnimate {
                if let existingOldController = oldController {
                    existingOldController.addToAnimationBlock(.Inactive)
                    if !existingOldController.managesOwnTransitions() {
                        existingOldController.view.alpha = 0
                        existingOldController.view.transform = CGAffineTransformMakeScale(self.transitionEndScale, self.transitionEndScale)
                    }
                }
                if let existingNewController = newController {
                    existingNewController.addToAnimationBlock(.Active)
                    if !existingNewController.managesOwnTransitions() {
                        existingNewController.view.alpha = 1.0
                        existingNewController.view.transform = CGAffineTransformMakeScale(1.0, 1.0)
                    }
                }
            }
        }) { (finished: Bool) in
            assert(NSThread.isMainThread(), "Expecting the animation completion to be executed on the main thread")
            for (oldController, _) in controllersToAnimate {
                if let existingOldController = oldController {
                    existingOldController.willMoveToParentViewController(nil)
                    let superviewHalf = existingOldController.view.superview
                    existingOldController.view.removeFromSuperview()
                    existingOldController.removeFromParentViewController()
                    superviewHalf?.removeConstraints(constraintsToRemove)
                }
            }
            
            self.transitionQueue.removeAtIndex(0)
            self.transition()
        }
        
        self.topViewController = newTopViewController
        self.bottomViewController = newBottomViewController
        
        func doAfterRandomTimeout(work: () -> Void) {
            let minTimeout = 5.0 + DesignLanguage.TransitionAnimationDuration
            let maxTimeout = minTimeout + 25.0
            let timeout = (Double(arc4random()) / Double(UINT32_MAX))*(maxTimeout - minTimeout) + minTimeout
            let dispatchTime = dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(timeout * Double(NSEC_PER_SEC))
            )
            dispatch_after(dispatchTime, dispatch_get_main_queue(), work)
        }
        
        if topViewController?.isPurelyDecorative() ?? false {
            let requiredOldVc = topViewController
            doAfterRandomTimeout {
                self.queueTransition(newTopViewControllerFunc:newTopViewControllerFunc, checkTopViewController: requiredOldVc)
            }
        }
        if bottomViewController?.isPurelyDecorative() ?? false {
            let requiredOldVc = bottomViewController
            doAfterRandomTimeout {
                self.queueTransition(newBottomViewControllerFunc: newBottomViewControllerFunc, checkBottomViewController: requiredOldVc)
            }
        }
    }
    
    private func getControllersToAnimate(#oldController: HalfScreenViewController?, newController: HalfScreenViewController?) -> (HalfScreenViewController?, HalfScreenViewController?) {
        if oldController != nil && oldController! == newController {
            // The two controllers are the same – nothing to animate
            return (nil, nil);
        } else {
            return (oldController, newController);
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
}


extension BaseViewController: GameStateChangeListener {
    func gameStateChanged(change: GameStateChange) {
        if change.newGameState != nil && (change.oldGameState?.gameId ?? "") != change.newGameState!.gameId {
            queueTransition(
                newTopViewControllerFunc: { return GameplayOutputViewController(gameState: change.newGameState!) },
                newBottomViewControllerFunc: { return GameplayInputController(delegate: GameManager.sharedInstance) }
            )
        } else if change.oldGameState != nil && change.newGameState == nil {
            queueTransition(
                newTopViewControllerFunc: { return LogoViewController() },
                newBottomViewControllerFunc: { return LevelPickerViewController(delegate: GameManager.sharedInstance) }
            )
        } else if change.newGameState?.currentChallengeIndex >= change.newGameState?.challenges.count {
            queueTransition(
                newTopViewControllerFunc: { return GameResultViewController(gameState: change.newGameState!) },
                newBottomViewControllerFunc: { return SharingViewController(gameState: change.newGameState!) }
            )
        }
    }
}

enum TransitionAnimationState {
    case Inactive
    case Active
}

protocol TransitionAnimationDelegate {
    func animationWillBegin(beginningState: TransitionAnimationState, plannedAnimationDuration: NSTimeInterval)
    func addToAnimationBlock(endingState: TransitionAnimationState)
    func managesOwnTransitions() -> Bool
    func isPurelyDecorative() -> Bool
}