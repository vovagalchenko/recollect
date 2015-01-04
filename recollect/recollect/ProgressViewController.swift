//
//  ProgressViewController.swift
//  recollect
//
//  Created by Vova Galchenko on 1/1/15.
//  Copyright (c) 2015 Vova Galchenko. All rights reserved.
//

import UIKit

class ProgressViewController: UIViewController {
    
    var gameState: GameState?
    
    private let dotsSpread: CGFloat = 80.0
    private var timeLabel: ManglableLabel?
    private var dotViews: [UILabel] = [UILabel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.setTranslatesAutoresizingMaskIntoConstraints(false)
        view.backgroundColor = DesignLanguage.BottomHalfBGColor
        
        let font = UIFont(name: "AvenirNextCondensed-DemiBold", size: 25.0)
        timeLabel = ManglableLabel()
        timeLabel?.setTranslatesAutoresizingMaskIntoConstraints(false)
        timeLabel?.backgroundColor = UIColor.clearColor()
        timeLabel?.textColor = DesignLanguage.NeverActiveTextColor.colorWithAlphaComponent(0.30)
        timeLabel?.font = font
        timeLabel?.text = "00:00:00"
        view.addSubview(timeLabel!)
        
        view.addConstraints(
            [
                NSLayoutConstraint(
                    item: timeLabel!,
                    attribute: NSLayoutAttribute.CenterX,
                    relatedBy: NSLayoutRelation.Equal,
                    toItem: view,
                    attribute: NSLayoutAttribute.CenterX,
                    multiplier: 1.0,
                    constant: 0.0),
                NSLayoutConstraint(
                    item: timeLabel!,
                    attribute: NSLayoutAttribute.CenterY,
                    relatedBy: NSLayoutRelation.Equal,
                    toItem: view,
                    attribute: NSLayoutAttribute.CenterY,
                    multiplier: 1.0,
                    constant: 0.0)
            ]
        )
        
        for i in 1...(gameState!.challenges.count) {
            let dotLabel = UILabel()
            dotLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
            dotLabel.backgroundColor = UIColor.clearColor()
            dotLabel.font = font
            dotLabel.text = "."
            view.addSubview(dotLabel)
            dotViews.append(dotLabel)
            
            view.addConstraints(
                [
                    NSLayoutConstraint(
                        item: dotLabel,
                        attribute: NSLayoutAttribute.CenterX,
                        relatedBy: NSLayoutRelation.Equal,
                        toItem: view,
                        attribute: NSLayoutAttribute.CenterX,
                        multiplier: 1.0,
                        constant: -(dotsSpread/2.0) + ((dotsSpread*CGFloat(i - 1))/CGFloat(gameState!.challenges.count - 1))),
                    NSLayoutConstraint(
                        item: dotLabel,
                        attribute: NSLayoutAttribute.CenterY,
                        relatedBy: NSLayoutRelation.Equal,
                        toItem: view,
                        attribute: NSLayoutAttribute.Bottom,
                        multiplier: 0.70,
                        constant: 0)
                ]
            )
        }
        
        let bottomShadow = UIView()
        bottomShadow.setTranslatesAutoresizingMaskIntoConstraints(false)
        bottomShadow.backgroundColor = DesignLanguage.ShadowColor
        view.addSubview(bottomShadow)
        
        view.addConstraints(
            NSLayoutConstraint.constraintsWithVisualFormat(
                "H:|[bottomShadow]|",
                options: NSLayoutFormatOptions(0),
                metrics: nil,
                views: ["bottomShadow" : bottomShadow]) +
            NSLayoutConstraint.constraintsWithVisualFormat(
                "V:[bottomShadow(1)]|",
                options: NSLayoutFormatOptions(0),
                metrics: nil,
                views: ["bottomShadow" : bottomShadow])
        )
        
        GameManager.sharedInstance.subscribeToGameStateChangeNotifications(self)
        
        refreshDotViews()
    }
    
    deinit {
        GameManager.sharedInstance.unsubscribeFromGameStateChangeNotifications(self)
    }
    
    private func refreshDotViews() {
        let currChallengeIndex = gameState?.currentChallengeIndex ?? Int.max
        for (dotViewIndex, dotView) in enumerate(self.dotViews) {
            dotView.textColor = (dotViewIndex >= currChallengeIndex) ? DesignLanguage.ActiveTextColor : DesignLanguage.InactiveTextColor
        }
    }
    
    func refresh(displayLink: CADisplayLink) {
        if let gameStartTime = gameState?.timeStart {
            let timeInGame = NSDate().timeIntervalSinceDate(gameStartTime)
            let minsInGame = Int(floor(timeInGame/60.0))
            let secsInGame = Int(floor(timeInGame - NSTimeInterval(minsInGame*60)))
            let hundredthsOfSecsInGame = Int(floor((timeInGame - floor(timeInGame))*100))
            timeLabel?.text = NSString(format: "%02d:%02d:%02d", minsInGame, secsInGame, hundredthsOfSecsInGame)
        } else {
            displayLink.invalidate()
        }
    }
}

extension ProgressViewController: GameStateChangeListener {
    func gameStateChanged(change: GameStateChange) {
        gameState = change.newGameState
        if change.oldGameState?.timeStart == nil && change.newGameState?.timeStart != nil {
            let displayLink = CADisplayLink(target: self, selector: "refresh:")
            displayLink.addToRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
        }
        refreshDotViews()
    }
}
