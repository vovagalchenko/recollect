//
//  GameResultViewController.swift
//  recollect
//
//  Created by Vova Galchenko on 1/5/15.
//  Copyright (c) 2015 Vova Galchenko. All rights reserved.
//

import UIKit

class GameResultViewController: HalfScreenViewController, UIGestureRecognizerDelegate, PlayerIdentityChangeListener {
    
    let gameState: GameState
    
    var resultViewContainer: UIView?
    var completionMsgLabel: ManglableLabel?
    var mainTimeLabel: ManglableLabel?
    var deltaTimeLabel: ManglableLabel?
    var gameCenterSolicitationLabel: ManglableLabel?
    var resultViewContainerVerticalConstraint: NSLayoutConstraint?
    var leaderboardVC: LeaderboardViewController!
    
    init(gameState: GameState) {
        self.gameState = gameState
        super.init(nibName: nil, bundle: nil)
        
        PlayerIdentityManager.sharedInstance.subscribeToPlayerIdentityChangeNotifications(self)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) won't be implemented because I ain't using xibs")
    }
    
    deinit {
        PlayerIdentityManager.sharedInstance.unsubscribeFromPlayerIdentityChangeNotifications(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        resultViewContainer = UIView()
        resultViewContainer!.backgroundColor = UIColor.clearColor()
        resultViewContainer!.setTranslatesAutoresizingMaskIntoConstraints(false)
        resultViewContainer!.setContentHuggingPriority(1000, forAxis: UILayoutConstraintAxis.Vertical)
        view.addSubview(resultViewContainer!)
        
        let completionMsgLabelHeight = CGFloat(26.5)
        let mainTimeLabelHeight = CGFloat(53.5)
        let deltaTimeLabelHeight = CGFloat(25.0)
        
        completionMsgLabel = ManglableLabel()
        completionMsgLabel!.setContentHuggingPriority(1000, forAxis: UILayoutConstraintAxis.Vertical)
        completionMsgLabel!.setContentCompressionResistancePriority(1000, forAxis: UILayoutConstraintAxis.Vertical)
        completionMsgLabel!.font = UIFont(name: "AvenirNextCondensed-DemiBold", size: completionMsgLabelHeight)
        completionMsgLabel!.textColor = DesignLanguage.NeverActiveTextColor
        completionMsgLabel!.adjustsFontSizeToFitWidth = true
        completionMsgLabel!.minimumScaleFactor = 0.5
        completionMsgLabel!.text = "Level \(gameState.levelId) completed!"
        resultViewContainer!.addSubview(completionMsgLabel!)
        
        mainTimeLabel = ManglableLabel()
        mainTimeLabel!.setContentHuggingPriority(1000, forAxis: UILayoutConstraintAxis.Vertical)
        mainTimeLabel!.setContentCompressionResistancePriority(1000, forAxis: UILayoutConstraintAxis.Vertical)
        mainTimeLabel!.font = UIFont(name: "AvenirNextCondensed-DemiBold", size: mainTimeLabelHeight)
        mainTimeLabel!.textColor = DesignLanguage.ActiveTextColor
        mainTimeLabel!.text = gameState.finalTime().minuteSecondCentisecondString()
        resultViewContainer!.addSubview(mainTimeLabel!)
        
        deltaTimeLabel = ManglableLabel()
        deltaTimeLabel!.setContentHuggingPriority(1000, forAxis: UILayoutConstraintAxis.Vertical)
        deltaTimeLabel!.setContentCompressionResistancePriority(1000, forAxis: UILayoutConstraintAxis.Vertical)
        deltaTimeLabel!.font = UIFont(name: "AvenirNextCondensed-DemiBold", size: deltaTimeLabelHeight)
        deltaTimeLabel!.textAlignment = NSTextAlignment.Right
        deltaTimeLabel!.textColor = DesignLanguage.NeverActiveTextColor
        deltaTimeLabel!.text = NSTimeInterval(0).minuteSecondCentisecondString(signed: true)
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
        gameCenterSolicitationLabel!.userInteractionEnabled = true
        let tapRecognizer = UITapGestureRecognizer()
        tapRecognizer.delegate = self
        tapRecognizer.addTarget(self, action: "loginViaGameCenterLabelTapped:")
        gameCenterSolicitationLabel!.addGestureRecognizer(tapRecognizer)
        view.addSubview(gameCenterSolicitationLabel!)
        
        leaderboardVC = LeaderboardViewController()
        addChildViewController(leaderboardVC)
        view.addSubview(leaderboardVC.view)
        leaderboardVC.didMoveToParentViewController(self)
        
        view.addConstraints(
            NSLayoutConstraint.constraintsWithVisualFormat(
                "H:|[leaderboardView]|",
                options: NSLayoutFormatOptions(0),
                metrics: nil,
                views: ["leaderboardView": leaderboardVC.view]) +
            NSLayoutConstraint.constraintsWithVisualFormat(
                "V:[leaderboardView]|",
                options: NSLayoutFormatOptions(0),
                metrics: nil,
                views: ["leaderboardView": leaderboardVC.view])
        )
        
        resultViewContainerVerticalConstraint = NSLayoutConstraint(
            item: resultViewContainer!,
            attribute: NSLayoutAttribute.CenterY,
            relatedBy: NSLayoutRelation.Equal,
            toItem: view,
            attribute: NSLayoutAttribute.CenterY,
            multiplier: 1.0,
            constant: 0.0)
        view.addConstraints([
            resultViewContainerVerticalConstraint!,
            NSLayoutConstraint(
                item: leaderboardVC.view,
                attribute: .Top,
                relatedBy: .Equal,
                toItem: resultViewContainer!,
                attribute: .Bottom,
                multiplier: 1.0,
                constant: 0.0
            ),
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
        refreshLayout()
        PlayerIdentityManager.sharedInstance.presentGameCenterLoginViewControllerIfAvailable()
    }
    
    func playerIdentityChanged(oldIdentity: PlayerIdentity, newIdentity: PlayerIdentity) {
        if isViewLoaded() { refreshLayout() }
    }
    
    func loginViaGameCenterLabelTapped(tapRecognizer: UITapGestureRecognizer) {
        UIApplication.sharedApplication().openURL(NSURL(string: "gamecenter:")!)
    }
    
    func refreshLayout() {
        let identity = PlayerIdentityManager.sharedInstance.currentIdentity
        identity.getMyBestScores { usersOldBestScores in
            self.refreshThisGameInfo(usersOldBestScores[self.gameState.levelId])
            identity.recordNewGame(self.gameState) {
                identity.getLeaderboard(self.gameState.levelId, ownForcedScore: self.gameState.finalTime()) { (leaderboard: Leaderboard) -> Void in
                    logDebug("got_leaderboard", [
                        "current_score": self.gameState.finalTime(),
                        "leaderboard": leaderboard.entries.map() {
                            return [
                                "rank": $0.rank,
                                "player_name": $0.playerName,
                                "score": $0.time
                            ]
                        }
                    ])
                    self.refreshLeaderboard(identity: identity, leaderboard: leaderboard)
                }
            }
        }
    }
    
    func refreshThisGameInfo(oldBestScore: PlayerScore?) {
        let delta = gameState.finalTime() - (oldBestScore?.time ?? gameState.finalTime())
        let deltaAlpha: CGFloat
        let deltaTextColor: UIColor
        if delta != 0 {
            deltaTimeLabel!.text = delta.minuteSecondCentisecondString(signed: true)
            deltaAlpha = 1.0
            deltaTextColor = delta > 0 ? DesignLanguage.NegativeAccentTextColor : DesignLanguage.NeverActiveTextColor
        } else {
            deltaAlpha = 0.0
            deltaTextColor = UIColor.blackColor()
        }
        UIView.animateWithDuration(DesignLanguage.MinorAnimationDuration) {
            self.deltaTimeLabel?.alpha = deltaAlpha
            self.deltaTimeLabel?.textColor = deltaTextColor
        }
    }
    
    func refreshLeaderboard(#identity: PlayerIdentity, leaderboard: Leaderboard) {
        view.layoutIfNeeded()
        
        gameCenterSolicitationLabel?.attributedText = NSAttributedString(
            string: PlayerIdentityManager.sharedInstance.currentIdentity is GameCenterPlayerIdentity ? "See the full leaderboard" : "Log in via Game Center",
            attributes: [
                NSFontAttributeName: UIFont(name: "AvenirNext-Regular", size: 17.5)!,
                NSForegroundColorAttributeName: DesignLanguage.ActiveTextColor,
                NSUnderlineStyleAttributeName: 1,
            ]
        )
        
        UIView.animateWithDuration(DesignLanguage.MinorAnimationDuration) {
            if let resultsContainerConstraint = self.resultViewContainerVerticalConstraint {
                self.view.removeConstraint(resultsContainerConstraint)
            }
            self.resultViewContainerVerticalConstraint = leaderboard.entries.count > 1 ?
                NSLayoutConstraint(
                    item: self.resultViewContainer!,
                    attribute: .Top,
                    relatedBy: .Equal,
                    toItem: self.view,
                    attribute: .Top,
                    multiplier: 1.0,
                    constant: self.topLayoutGuide.length) :
                NSLayoutConstraint(
                    item: self.resultViewContainer!,
                    attribute: NSLayoutAttribute.CenterY,
                    relatedBy: NSLayoutRelation.Equal,
                    toItem: self.view,
                    attribute: NSLayoutAttribute.CenterY,
                    multiplier: 1.0,
                    constant: 0.0)
            self.view.addConstraint(self.resultViewContainerVerticalConstraint!)
            if 2...4 ~= leaderboard.entries.count {
                self.leaderboardVC.setLeaderboard(leaderboard)
            }
            self.view.layoutIfNeeded()
            self.gameCenterSolicitationLabel?.alpha = leaderboard.entries.count <= 1 ? 1.0 : 0.0
            self.leaderboardVC.view.alpha = 2...4 ~= leaderboard.entries.count ? 1.0 : 0.0
        }
    }
}
