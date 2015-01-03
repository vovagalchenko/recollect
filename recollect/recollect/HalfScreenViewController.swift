//
//  HalfScreenViewController.swift
//  recollect
//
//  Created by Vova Galchenko on 12/28/14.
//  Copyright (c) 2014 Vova Galchenko. All rights reserved.
//

import UIKit

class HalfScreenViewController: UIViewController, TransitionAnimationDelegate {
    var displayLinkStartDate: NSDate?
    var displayLinkDuration: NSTimeInterval?
    var transitionBeginningState: TransitionAnimationState?
    
    let labelSettlingDuration: NSTimeInterval = 0.5
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.setTranslatesAutoresizingMaskIntoConstraints(false)
        for c in view.constraints() {
            if let constraint = c as? NSLayoutConstraint {
                constraint.shouldBeArchived = true
            }
        }
    }
    
    private func subviewsWalk(root: UIView, work: (UIView) -> Void) {
        work(root)
        for subview in root.subviews {
            subviewsWalk(subview as UIView, work: work)
        }
    }
    
    func refreshFrame(displayLink: CADisplayLink) {
        let timeElapsed = NSDate().timeIntervalSinceDate(displayLinkStartDate!)
        let timeLeft = displayLinkDuration! - timeElapsed
        subviewsWalk(view) {
            if let label = $0 as? ManglableLabel {
                var portionToLeaveUnmangled: Float = 0
                if (timeLeft <= self.labelSettlingDuration) {
                    let portionOfScreenToLeaveUnmangled = CGFloat((self.labelSettlingDuration - timeLeft)/self.labelSettlingDuration)
                    let rectToLeaveUnmangled = CGRectMake(0, 0, self.view.bounds.size.width*portionOfScreenToLeaveUnmangled, self.view.bounds.size.height)
                    let labelRect = label.superview!.convertRect(label.frame, toView: self.view)
                    let labelRectToLeaveUnmangled = CGRectIntersection(rectToLeaveUnmangled, labelRect)
                    if (labelRect.width > 0) {
                        portionToLeaveUnmangled = Float(labelRectToLeaveUnmangled.width/labelRect.width)
                    } else {
                        portionToLeaveUnmangled = 0
                    }
                }
                label.mangle(portionToLeaveUnmangled,
                    canUseAlphaForAccents: self.transitionBeginningState! == TransitionAnimationState.Inactive)
            }
        }
        
        if timeElapsed >= displayLinkDuration {
            displayLink.invalidate()
            displayLinkDuration = nil
            displayLinkStartDate = nil
            transitionBeginningState = nil
            
            subviewsWalk(view) {
                if let label = $0 as? ManglableLabel {
                    label.unmangle()
                }
            }
        }
    }
    
    func animationWillBegin(beginningState: TransitionAnimationState, plannedAnimationDuration: NSTimeInterval) {
        let displayLink = CADisplayLink(target: self, selector: Selector("refreshFrame:"))
        transitionBeginningState = beginningState
        displayLinkStartDate = NSDate()
        displayLinkDuration = plannedAnimationDuration
        
        displayLink?.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSDefaultRunLoopMode)
    }
    
    func addToAnimationBlock(endingState: TransitionAnimationState) { }
    
    func managesOwnTransitions() -> Bool {
        return false
    }
    
    func isPurelyDecorative() -> Bool {
        return false;
    }
}