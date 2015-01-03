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
    var topAndBottomViewConstraints: [AnyObject]? = nil
    
    var bottomHalfContainerView: UIView?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = DesignLanguage.TopHalfBGColor
        bottomHalfContainerView = UIView()
        bottomHalfContainerView!.clipsToBounds = true
        bottomHalfContainerView!.backgroundColor = DesignLanguage.BottomHalfBGColor
        bottomHalfContainerView!.setTranslatesAutoresizingMaskIntoConstraints(false)
        view.addSubview(bottomHalfContainerView!)
        view.addConstraints([
            NSLayoutConstraint(
                item: bottomHalfContainerView!,
                attribute: NSLayoutAttribute.CenterX,
                relatedBy: NSLayoutRelation.Equal,
                toItem: view,
                attribute: NSLayoutAttribute.CenterX,
                multiplier: 1.0,
                constant: 0.0),
            NSLayoutConstraint(
                item: bottomHalfContainerView!,
                attribute: NSLayoutAttribute.CenterY,
                relatedBy: NSLayoutRelation.Equal,
                toItem: view,
                attribute: NSLayoutAttribute.CenterY,
                multiplier: 1.5,
                constant: 0.0),
            NSLayoutConstraint(
                item: bottomHalfContainerView!,
                attribute: NSLayoutAttribute.Width,
                relatedBy: NSLayoutRelation.Equal,
                toItem: view,
                attribute: NSLayoutAttribute.Width,
                multiplier: 1.0,
                constant: 0.0),
            NSLayoutConstraint(
                item: bottomHalfContainerView!,
                attribute: NSLayoutAttribute.Height,
                relatedBy: NSLayoutRelation.Equal,
                toItem: view,
                attribute: NSLayoutAttribute.Height,
                multiplier: 0.5,
                constant: 0.0)
        ])
        
        queueTransition(newTopViewControllerFunc: { return LogoViewController() }, newBottomViewControllerFunc: {
            let levelPickerVC = LevelPickerViewController()
            levelPickerVC.delegate = GameManager.sharedInstance
            return levelPickerVC
        })
        
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: "gameStateChangeNotificationReceived:",
            name: GameManager.GameStateChangeNotificationName,
            object: GameManager.sharedInstance)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
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
        for (oldController, newController) in controllersToAnimate {
            if let existingOldController = oldController {
                existingOldController.animationWillBegin(.Active, plannedAnimationDuration: DesignLanguage.TransitionAnimationDuration)
            }
            if let existingNewController = newController {
                existingNewController.view.alpha = existingNewController.managesOwnTransitions() ? 1.0 : 0.0
                
                existingNewController.animationWillBegin(.Inactive, plannedAnimationDuration: DesignLanguage.TransitionAnimationDuration)
                
                self.addChildViewController(existingNewController)
                let isTop = existingNewController == newTopViewController
                let viewToAddTo = isTop ? self.view : self.bottomHalfContainerView!
                viewToAddTo.addSubview(existingNewController.view)
                viewToAddTo.sendSubviewToBack(existingNewController.view)
                existingNewController.didMoveToParentViewController(self)
                
                newViewConstraints.extend(newConstraints(existingNewController, isTop: isTop))
                
                if !existingNewController.managesOwnTransitions() {
                    existingNewController.view.transform = CGAffineTransformMakeScale(transitionStartScale, transitionStartScale)
                }
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
                    existingOldController.view.removeFromSuperview()
                    existingOldController.removeFromParentViewController()
                }
            }
            if let existingTopAndBottomViewConstraints = self.topAndBottomViewConstraints {
                let shouldRemove = { (c: AnyObject) -> Bool in
                    if let existingConstraint = c as? NSLayoutConstraint {
                        return animatingOutViews.filter { $0 == existingConstraint.firstItem as NSObject }.count > 0
                    } else {
                        return false
                    }
                }
                let constraintsToRemove = existingTopAndBottomViewConstraints.filter(shouldRemove)
                self.view.removeConstraints(constraintsToRemove)
                self.topAndBottomViewConstraints = existingTopAndBottomViewConstraints.filter { !shouldRemove($0) } + newViewConstraints
            } else {
                self.topAndBottomViewConstraints = newViewConstraints
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
    
    private func newConstraints(newTopViewController: HalfScreenViewController, isTop: Bool) -> [AnyObject] {
        return [
            NSLayoutConstraint(item: newTopViewController.view!,
                attribute: NSLayoutAttribute.CenterX,
                relatedBy: NSLayoutRelation.Equal,
                toItem: self.view!,
                attribute: NSLayoutAttribute.CenterX,
                multiplier: 1.0,
                constant: 0.0),
            NSLayoutConstraint(item: newTopViewController.view!,
                attribute: NSLayoutAttribute.CenterY,
                relatedBy: NSLayoutRelation.Equal,
                toItem: self.view!,
                attribute: NSLayoutAttribute.CenterY,
                multiplier: isTop ? 0.5 : 1.5,
                constant: 0.0),
            NSLayoutConstraint(item: newTopViewController.view!,
                attribute: NSLayoutAttribute.Width,
                relatedBy: NSLayoutRelation.Equal,
                toItem: self.view!,
                attribute: NSLayoutAttribute.Width,
                multiplier: 1.0,
                constant: 0.0),
            NSLayoutConstraint(item: newTopViewController.view!,
                attribute: NSLayoutAttribute.Height,
                relatedBy: NSLayoutRelation.Equal,
                toItem: self.view!,
                attribute: NSLayoutAttribute.Height,
                multiplier: 0.5,
                constant: 0.0)
        ]
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


extension BaseViewController {
    func gameStateChangeNotificationReceived(notification: NSNotification!) {
        let change = notification!.userInfo![GameManager.GameStateChangeUserInfoKey]! as GameStateChange
        if change.oldGameState == nil && change.newGameState != nil {
            self.queueTransition(newTopViewControllerFunc: {
                let gameplayOutputController = GameplayOutputViewController()
                gameplayOutputController.gameState = change.newGameState
                return gameplayOutputController
                }, newBottomViewControllerFunc: {
                    let gameplayInputController = GameplayInputController()
                    gameplayInputController.delegate = GameManager.sharedInstance
                    return gameplayInputController
            })
        } else if change.oldGameState != nil && change.newGameState == nil {
            self.queueTransition(newTopViewControllerFunc: { return LogoViewController() }, newBottomViewControllerFunc: {
                let levelPicker = LevelPickerViewController()
                levelPicker.delegate = GameManager.sharedInstance
                return levelPicker
            })
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