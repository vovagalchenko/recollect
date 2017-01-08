//
//  HalfScreenViewController.swift
//  recollect
//
//  Created by Vova Galchenko on 12/28/14.
//  Copyright (c) 2014 Vova Galchenko. All rights reserved.
//

import UIKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
private func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
private func >= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l >= r
  default:
    return !(lhs < rhs)
  }
}


class HalfScreenViewController: UIViewController, TransitionAnimationDelegate {
    var displayLinkStartDate: Date?
    var displayLinkDuration: Foundation.TimeInterval?
    var transitionBeginningState: TransitionAnimationState?
    
    let labelSettlingDuration: Foundation.TimeInterval = 0.5
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.translatesAutoresizingMaskIntoConstraints = false
        for c in view.constraints {
            c.shouldBeArchived = true
        }
    }
    
    private func subviewsWalk(_ root: UIView, work: (UIView) -> Void) {
        work(root)
        for subview in root.subviews {
            subviewsWalk(subview, work: work)
        }
    }
    
    func refreshFrame(_ displayLink: CADisplayLink) {
        if let existingDisplayLinkStartDate = displayLinkStartDate {
            let timeElapsed = Date().timeIntervalSince(existingDisplayLinkStartDate)
            let timeLeft = displayLinkDuration! - timeElapsed
            subviewsWalk(view) {
                if let label = $0 as? ManglableLabel {
                    var portionToLeaveUnmangled: Float = 0
                    if (timeLeft <= self.labelSettlingDuration) {
                        let portionOfScreenToLeaveUnmangled = CGFloat((self.labelSettlingDuration - timeLeft)/self.labelSettlingDuration)
                        let rectToLeaveUnmangled = CGRect(x: 0, y: 0, width: self.view.bounds.size.width*portionOfScreenToLeaveUnmangled, height: self.view.bounds.size.height)
                        let labelRect = label.superview!.convert(label.frame, to: self.view)
                        let labelRectToLeaveUnmangled = rectToLeaveUnmangled.intersection(labelRect)
                        if (labelRect.width > 0) {
                            portionToLeaveUnmangled = Float(labelRectToLeaveUnmangled.width/labelRect.width)
                        } else {
                            portionToLeaveUnmangled = 0
                        }
                    }
                    label.mangle(portionToLeaveUnmangled,
                        canUseAlphaForAccents: self.transitionBeginningState! == TransitionAnimationState.inactive)
                }
            }
        }
        
        if displayLinkStartDate == nil || Date().timeIntervalSince(displayLinkStartDate!) >= displayLinkDuration {
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
    
    func animationWillBegin(beginningState: TransitionAnimationState, plannedAnimationDuration: Foundation.TimeInterval) {
        let displayLink = CADisplayLink(target: self, selector: #selector(HalfScreenViewController.refreshFrame(_:)))
        transitionBeginningState = beginningState
        displayLinkStartDate = Date()
        displayLinkDuration = plannedAnimationDuration
        
        displayLink.add(to: RunLoop.main, forMode: RunLoopMode.defaultRunLoopMode)
    }
    
    func addToAnimationBlock(endingState: TransitionAnimationState) { }
    
    func managesOwnTransitions() -> Bool {
        return false
    }
    
    func isPurelyDecorative() -> Bool {
        return false;
    }
}
