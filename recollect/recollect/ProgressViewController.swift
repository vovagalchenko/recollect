//
//  ProgressViewController.swift
//  recollect
//
//  Created by Vova Galchenko on 1/1/15.
//  Copyright (c) 2015 Vova Galchenko. All rights reserved.
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


class ProgressViewController: UIViewController {
    
    var gameState: GameState?
    
    private let dotsSpread: CGFloat = 80.0
    fileprivate var timeLabel: ManglableLabel?
    private var dotViews: [UILabel] = [UILabel]()
    private var penaltyLabel: UILabel?
    private let penaltyLabelStartTranslation = CGAffineTransform(scaleX: 0.9, y: 0.9)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = DesignLanguage.BottomHalfBGColor
        
        let font = UIFont(name: "AvenirNextCondensed-DemiBold", size: 25.0)
        timeLabel = ManglableLabel()
        timeLabel?.backgroundColor = UIColor.clear
        timeLabel?.textColor = DesignLanguage.NeverActiveTextColor.withAlphaComponent(0.30)
        timeLabel?.font = font
        timeLabel?.text = Foundation.TimeInterval(0).minuteSecondCentisecondString()
        view.addSubview(timeLabel!)
        
        view.addConstraints(
            [
                NSLayoutConstraint(
                    item: timeLabel!,
                    attribute: NSLayoutAttribute.centerX,
                    relatedBy: NSLayoutRelation.equal,
                    toItem: view,
                    attribute: NSLayoutAttribute.centerX,
                    multiplier: 1.0,
                    constant: 0.0),
                NSLayoutConstraint(
                    item: timeLabel!,
                    attribute: NSLayoutAttribute.centerY,
                    relatedBy: NSLayoutRelation.equal,
                    toItem: view,
                    attribute: NSLayoutAttribute.centerY,
                    multiplier: 1.0,
                    constant: 0.0)
            ]
        )
        
        for i in 1...(gameState!.challenges.count) {
            let dotLabel = UILabel()
            dotLabel.translatesAutoresizingMaskIntoConstraints = false
            dotLabel.backgroundColor = UIColor.clear
            dotLabel.font = font
            dotLabel.text = "."
            view.addSubview(dotLabel)
            dotViews.append(dotLabel)
            
            view.addConstraints(
                [
                    NSLayoutConstraint(
                        item: dotLabel,
                        attribute: NSLayoutAttribute.centerX,
                        relatedBy: NSLayoutRelation.equal,
                        toItem: view,
                        attribute: NSLayoutAttribute.centerX,
                        multiplier: 1.0,
                        constant: -(dotsSpread/2.0) + ((dotsSpread*CGFloat(i - 1))/CGFloat(gameState!.challenges.count - 1))),
                    NSLayoutConstraint(
                        item: dotLabel,
                        attribute: NSLayoutAttribute.centerY,
                        relatedBy: NSLayoutRelation.equal,
                        toItem: view,
                        attribute: NSLayoutAttribute.bottom,
                        multiplier: 0.70,
                        constant: 0)
                ]
            )
        }
        
        let bottomShadow = UIView()
        bottomShadow.translatesAutoresizingMaskIntoConstraints = false
        bottomShadow.backgroundColor = DesignLanguage.ShadowColor
        view.addSubview(bottomShadow)
        
        view.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "H:|[bottomShadow]|",
                options: NSLayoutFormatOptions(rawValue: 0),
                metrics: nil,
                views: ["bottomShadow" : bottomShadow]) +
            NSLayoutConstraint.constraints(
                withVisualFormat: "V:[bottomShadow(1)]|",
                options: NSLayoutFormatOptions(rawValue: 0),
                metrics: nil,
                views: ["bottomShadow" : bottomShadow])
        )
        
        penaltyLabel = UILabel()
        penaltyLabel!.translatesAutoresizingMaskIntoConstraints = false
        penaltyLabel!.backgroundColor = UIColor.clear
        penaltyLabel!.font = font
        penaltyLabel!.textColor = DesignLanguage.AccentTextColor
        penaltyLabel!.text = GameManager.penaltyPerPeek.minuteSecondCentisecondString(true)
        penaltyLabel!.alpha = 0.0
        penaltyLabel!.transform = penaltyLabelStartTranslation
        view.addSubview(penaltyLabel!)
        
        view.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "V:|[penaltyLabel]|",
                options: NSLayoutFormatOptions(rawValue: 0),
                metrics: nil,
                views: ["penaltyLabel" : penaltyLabel!]) +
            NSLayoutConstraint.constraints(
                withVisualFormat: "H:[penaltyLabel]-|",
                options: NSLayoutFormatOptions(rawValue: 0),
                metrics: nil,
                views: ["penaltyLabel" : penaltyLabel!])
        )
        
        GameManager.sharedInstance.subscribeToGameStateChangeNotifications(self)
        
        refreshDotViews()
    }
    
    deinit {
        GameManager.sharedInstance.unsubscribeFromGameStateChangeNotifications(self)
    }
    
    fileprivate func pulsePenaltyLabel() {
        self.penaltyLabel?.transform = penaltyLabelStartTranslation
        UIView.animate(
            withDuration: DesignLanguage.MinorAnimationDuration,
            animations: { () -> Void in
                self.penaltyLabel!.alpha = 1.0
                self.penaltyLabel!.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            }, completion: { (finished: Bool) -> Void in
                
                UIView.animate(withDuration: DesignLanguage.MinorAnimationDuration, delay: DesignLanguage.MinorAnimationDuration/2.0, options: [], animations: { () -> Void in
                    self.penaltyLabel!.alpha = 0.0
                }, completion: nil)
        }) 
    }
    
    fileprivate func refreshDotViews() {
        let currChallengeIndex = gameState?.currentChallengeIndex ?? Int.max
        for (dotViewIndex, dotView) in self.dotViews.enumerated() {
            dotView.textColor = (dotViewIndex >= currChallengeIndex) ? DesignLanguage.ActiveTextColor : DesignLanguage.InactiveTextColor
        }
    }
    
    func refresh(_ displayLink: CADisplayLink) {
        if gameState?.latestTimeStart != nil {
            timeLabel?.text = gameState!.time().minuteSecondCentisecondString()
        } else {
            displayLink.invalidate()
        }
    }
}

extension ProgressViewController: GameStateChangeListener {
    func gameStateChanged(_ change: GameStateChange) {
        gameState = change.newGameState
        if let existingGameState = gameState {
            timeLabel?.text = existingGameState.time().minuteSecondCentisecondString()
            if change.oldGameState?.latestTimeStart == nil && existingGameState.latestTimeStart != nil {
                let displayLink = CADisplayLink(target: self, selector: #selector(ProgressViewController.refresh(_:)))
                displayLink.add(to: RunLoop.current, forMode: RunLoopMode.defaultRunLoopMode)
            }
            if change.oldGameState?.peeks.count < existingGameState.peeks.count {
                pulsePenaltyLabel()
            }
            refreshDotViews()
        }
        
    }
}
