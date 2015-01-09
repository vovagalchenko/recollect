//
//  GameResultViewController.swift
//  recollect
//
//  Created by Vova Galchenko on 1/5/15.
//  Copyright (c) 2015 Vova Galchenko. All rights reserved.
//

import UIKit

class GameResultViewController: HalfScreenViewController, UIGestureRecognizerDelegate {
    
    let gameState: GameState
    
    var resultViewContainer: UIView?
    var completionMsgLabel: ManglableLabel?
    var mainTimeLabel: ManglableLabel?
    var deltaTimeLabel: ManglableLabel?
    var gameCenterSolicitationLabel: ManglableLabel?
    var resultViewContainerVerticalConstraint: NSLayoutConstraint?
    
    init(gameState: GameState) {
        self.gameState = gameState
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        resultViewContainer = UIView()
        resultViewContainer!.setTranslatesAutoresizingMaskIntoConstraints(false)
        view.addSubview(resultViewContainer!)
        
        let completionMsgLabelHeight = CGFloat(26.5)
        let mainTimeLabelHeight = CGFloat(53.5)
        let deltaTimeLabelHeight = CGFloat(25.0)
        
        completionMsgLabel = ManglableLabel()
        completionMsgLabel!.font = UIFont(name: "AvenirNextCondensed-DemiBold", size: completionMsgLabelHeight)
        completionMsgLabel!.textColor = DesignLanguage.NeverActiveTextColor
        completionMsgLabel!.adjustsFontSizeToFitWidth = true
        completionMsgLabel!.minimumScaleFactor = 0.5
        completionMsgLabel!.text = "Level \(gameState.levelId) completed!"
        resultViewContainer!.addSubview(completionMsgLabel!)
        
        mainTimeLabel = ManglableLabel()
        mainTimeLabel!.font = UIFont(name: "AvenirNextCondensed-DemiBold", size: mainTimeLabelHeight)
        mainTimeLabel!.textColor = DesignLanguage.ActiveTextColor
        mainTimeLabel!.text = gameState.finalTime().minuteSecondCentisecondString()
        resultViewContainer!.addSubview(mainTimeLabel!)
        
        deltaTimeLabel = ManglableLabel()
        deltaTimeLabel!.font = UIFont(name: "AvenirNextCondensed-DemiBold", size: deltaTimeLabelHeight)
        deltaTimeLabel!.textAlignment = NSTextAlignment.Right
        deltaTimeLabel!.textColor = DesignLanguage.NeverActiveTextColor
        deltaTimeLabel!.text = "- 00:00:00"
        deltaTimeLabel!.alpha = 0.0
        resultViewContainer!.addSubview(deltaTimeLabel!)
        
        let resultLabelsConstraints: [AnyObject] = [
            NSLayoutConstraint(
                item: completionMsgLabel!,
                attribute: .Top,
                relatedBy: .Equal,
                toItem: resultViewContainer!,
                attribute: .Top,
                multiplier: 1.0,
                constant: 0.0),
            NSLayoutConstraint(
                item: deltaTimeLabel!,
                attribute: .Bottom,
                relatedBy: .Equal,
                toItem: resultViewContainer!,
                attribute: .Bottom,
                multiplier: 1.0,
                constant: 0.0),
            NSLayoutConstraint(
                item: mainTimeLabel!,
                attribute: .CenterY,
                relatedBy: .Equal,
                toItem: resultViewContainer!,
                attribute: .CenterY,
                multiplier: 1.0,
                constant: 0.0),
            NSLayoutConstraint(
                item: deltaTimeLabel!,
                attribute: .CenterY,
                relatedBy: .Equal,
                toItem: resultViewContainer!,
                attribute: .CenterY,
                multiplier: 1.0,
                constant: mainTimeLabelHeight/2.0 + deltaTimeLabelHeight/3.0),
            NSLayoutConstraint(
                item: completionMsgLabel!,
                attribute: .CenterY,
                relatedBy: .Equal,
                toItem: resultViewContainer!,
                attribute: .CenterY,
                multiplier: 1.0,
                constant: -(mainTimeLabelHeight/2.0 + completionMsgLabelHeight/3.0))
        ]
        resultViewContainer!.addConstraints(
            resultLabelsConstraints +
            NSLayoutConstraint.constraintsWithVisualFormat(
                "H:|[completionMsg]|",
                options: NSLayoutFormatOptions(0),
                metrics: nil,
                views: [
                    "completionMsg" : completionMsgLabel!,
                ]) +
            NSLayoutConstraint.constraintsWithVisualFormat(
                "H:|[mainTime]|",
                options: NSLayoutFormatOptions(0),
                metrics: nil,
                views: [
                    "mainTime" : mainTimeLabel!,
                ]) +
            NSLayoutConstraint.constraintsWithVisualFormat(
                "H:[deltaTime]|",
                options: NSLayoutFormatOptions(0),
                metrics: nil,
                views: [
                    "deltaTime" : deltaTimeLabel!,
                ])
        )
        
        gameCenterSolicitationLabel = ManglableLabel()
        gameCenterSolicitationLabel!.alpha = 0
        gameCenterSolicitationLabel!.attributedText = NSAttributedString(
            string: "Log in via Game Center",
            attributes: [
                NSFontAttributeName: UIFont(name: "AvenirNext-Regular", size: 17.5)!,
                NSForegroundColorAttributeName: DesignLanguage.ActiveTextColor,
                NSUnderlineStyleAttributeName: 1,
            ]
        )
        gameCenterSolicitationLabel!.userInteractionEnabled = true
        let tapRecognizer = UITapGestureRecognizer()
        tapRecognizer.delegate = self
        tapRecognizer.addTarget(self, action: "loginViaGameCenterLabelTapped:")
        gameCenterSolicitationLabel!.addGestureRecognizer(tapRecognizer)
        view.addSubview(gameCenterSolicitationLabel!)
        
        view.addConstraints([
            NSLayoutConstraint(
                item: resultViewContainer!,
                attribute: NSLayoutAttribute.CenterX,
                relatedBy: NSLayoutRelation.Equal,
                toItem: view,
                attribute: NSLayoutAttribute.CenterX,
                multiplier: 1.0,
                constant: 0.0
            ),
            NSLayoutConstraint(
                item: gameCenterSolicitationLabel!,
                attribute: NSLayoutAttribute.CenterX,
                relatedBy: NSLayoutRelation.Equal,
                toItem: view,
                attribute: NSLayoutAttribute.CenterX,
                multiplier: 1.0,
                constant: 0.0
            ),
            NSLayoutConstraint(
                item: gameCenterSolicitationLabel!,
                attribute: NSLayoutAttribute.Bottom,
                relatedBy: NSLayoutRelation.Equal,
                toItem: view,
                attribute: NSLayoutAttribute.Bottom,
                multiplier: 1.0,
                constant: -5.0 // a little breathing room never hurt nobody
            ),
        ])
        refreshLayout(identity: PlayerIdentityManager.identity(), leaderboard: [])
    }
    
    func loginViaGameCenterLabelTapped(tapRecognizer: UITapGestureRecognizer) {
        UIApplication.sharedApplication().openURL(NSURL(string: "gamecenter:")!)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        refreshLayout()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        PlayerIdentityManager.identity().flushBestGames(gameState)
    }
    
    func refreshLayout() {
        let identity = PlayerIdentityManager.identity()
        identity.submit(gameState) { (leaderboard: [PlayerScore]) -> Void in
            self.refreshLayout(identity: identity, leaderboard: leaderboard)
        }
    }
    
    func refreshLayout(#identity: PlayerIdentity, leaderboard: [PlayerScore]) {
        view.layoutIfNeeded()
        if let resultsContainerConstraint = resultViewContainerVerticalConstraint {
            view.removeConstraint(resultsContainerConstraint)
        }
        resultViewContainerVerticalConstraint = NSLayoutConstraint(
            item: resultViewContainer!,
            attribute: NSLayoutAttribute.CenterY,
            relatedBy: NSLayoutRelation.Equal,
            toItem: view,
            attribute: NSLayoutAttribute.CenterY,
            multiplier: 1.0,
            constant: 0.0)
        view.addConstraint(resultViewContainerVerticalConstraint!)
        
        let delta = identity.deltaFromBest(gameState)
        var deltaAlpha: CGFloat = 0.0
        if delta > 0 {
            deltaTimeLabel!.text = "+ " + delta.minuteSecondCentisecondString()
            deltaAlpha = 1.0
        } else if delta < 0 {
            deltaTimeLabel!.text = delta.minuteSecondCentisecondString()
            deltaAlpha = 1.0
        }
        
        UIView.animateWithDuration(DesignLanguage.MinorAnimationDuration) {
            self.view.layoutIfNeeded()
            self.deltaTimeLabel?.alpha = deltaAlpha
            self.gameCenterSolicitationLabel?.alpha = leaderboard.count <= 1 ? 1.0 : 0.0
        }
    }
}
