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
    var leaderboardVC: LeaderboardViewController!
    
    init(gameState: GameState) {
        self.gameState = gameState
        super.init(nibName: nil, bundle: nil)
        
        PlayerIdentityManager.sharedInstance.subscribeToPlayerIdentityChangeNotifications(self)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) won't be implemented because I ain't using xibs")
    }
    
    deinit {
        PlayerIdentityManager.sharedInstance.unsubscribeFromPlayerIdentityChangeNotifications(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        resultViewContainer = UIView()
        resultViewContainer!.backgroundColor = UIColor.clear
        resultViewContainer!.translatesAutoresizingMaskIntoConstraints = false
        resultViewContainer!.setContentHuggingPriority(1000, for: UILayoutConstraintAxis.vertical)
        view.addSubview(resultViewContainer!)
        
        let completionMsgLabelHeight = CGFloat(24.5)
        let mainTimeLabelHeight = CGFloat(50.5)
        let deltaTimeLabelHeight = CGFloat(24.0)
        
        completionMsgLabel = ManglableLabel()
        completionMsgLabel!.setContentHuggingPriority(1000, for: UILayoutConstraintAxis.vertical)
        completionMsgLabel!.setContentCompressionResistancePriority(1000, for: UILayoutConstraintAxis.vertical)
        completionMsgLabel!.font = UIFont(name: "AvenirNextCondensed-DemiBold", size: completionMsgLabelHeight)
        completionMsgLabel!.textColor = DesignLanguage.NeverActiveTextColor
        completionMsgLabel!.adjustsFontSizeToFitWidth = true
        completionMsgLabel!.minimumScaleFactor = 0.5
        completionMsgLabel!.text = "Level \(gameState.levelId) completed!"
        resultViewContainer!.addSubview(completionMsgLabel!)
        
        mainTimeLabel = ManglableLabel()
        mainTimeLabel!.setContentHuggingPriority(1000, for: UILayoutConstraintAxis.vertical)
        mainTimeLabel!.setContentCompressionResistancePriority(1000, for: UILayoutConstraintAxis.vertical)
        mainTimeLabel!.font = UIFont(name: "AvenirNextCondensed-DemiBold", size: mainTimeLabelHeight)
        mainTimeLabel!.textColor = DesignLanguage.ActiveTextColor
        mainTimeLabel!.text = gameState.finalTime().minuteSecondCentisecondString()
        resultViewContainer!.addSubview(mainTimeLabel!)
        
        deltaTimeLabel = ManglableLabel()
        deltaTimeLabel!.setContentHuggingPriority(1000, for: UILayoutConstraintAxis.vertical)
        deltaTimeLabel!.setContentCompressionResistancePriority(1000, for: UILayoutConstraintAxis.vertical)
        deltaTimeLabel!.font = UIFont(name: "AvenirNextCondensed-DemiBold", size: deltaTimeLabelHeight)
        deltaTimeLabel!.textAlignment = NSTextAlignment.right
        deltaTimeLabel!.textColor = DesignLanguage.NeverActiveTextColor
        deltaTimeLabel!.text = Foundation.TimeInterval(0).minuteSecondCentisecondString(true)
        deltaTimeLabel!.alpha = 0.0
        resultViewContainer!.addSubview(deltaTimeLabel!)
        
        let resultLabelsConstraints = [
            NSLayoutConstraint(
                item: completionMsgLabel!,
                attribute: .top,
                relatedBy: .equal,
                toItem: resultViewContainer!,
                attribute: .top,
                multiplier: 1.0,
                constant: 0.0),
            NSLayoutConstraint(
                item: deltaTimeLabel!,
                attribute: .bottom,
                relatedBy: .equal,
                toItem: resultViewContainer!,
                attribute: .bottom,
                multiplier: 1.0,
                constant: 0.0),
            NSLayoutConstraint(
                item: mainTimeLabel!,
                attribute: .centerY,
                relatedBy: .equal,
                toItem: resultViewContainer!,
                attribute: .centerY,
                multiplier: 1.0,
                constant: 0.0),
            NSLayoutConstraint(
                item: deltaTimeLabel!,
                attribute: .centerY,
                relatedBy: .equal,
                toItem: resultViewContainer!,
                attribute: .centerY,
                multiplier: 1.0,
                constant: mainTimeLabelHeight/2.0 + deltaTimeLabelHeight/3.0),
            NSLayoutConstraint(
                item: completionMsgLabel!,
                attribute: .centerY,
                relatedBy: .equal,
                toItem: resultViewContainer!,
                attribute: .centerY,
                multiplier: 1.0,
                constant: -(mainTimeLabelHeight/2.0 + completionMsgLabelHeight/3.0))
        ]
        resultViewContainer!.addConstraints(
            resultLabelsConstraints +
            NSLayoutConstraint.constraints(
                withVisualFormat: "H:|[completionMsg]|",
                options: NSLayoutFormatOptions(rawValue: 0),
                metrics: nil,
                views: [
                    "completionMsg" : completionMsgLabel!,
                ]) +
            NSLayoutConstraint.constraints(
                withVisualFormat: "H:|[mainTime]|",
                options: NSLayoutFormatOptions(rawValue: 0),
                metrics: nil,
                views: [
                    "mainTime" : mainTimeLabel!,
                ]) +
            NSLayoutConstraint.constraints(
                withVisualFormat: "H:[deltaTime]|",
                options: NSLayoutFormatOptions(rawValue: 0),
                metrics: nil,
                views: [
                    "deltaTime" : deltaTimeLabel!,
                ])
        )
        
        gameCenterSolicitationLabel = ManglableLabel()
        gameCenterSolicitationLabel!.alpha = 0
        gameCenterSolicitationLabel!.isUserInteractionEnabled = true
        let tapRecognizer = UITapGestureRecognizer()
        tapRecognizer.delegate = self
        tapRecognizer.addTarget(self, action: #selector(GameResultViewController.loginViaGameCenterLabelTapped(_:)))
        gameCenterSolicitationLabel!.addGestureRecognizer(tapRecognizer)
        view.addSubview(gameCenterSolicitationLabel!)
        
        leaderboardVC = LeaderboardViewController()
        addChildViewController(leaderboardVC)
        view.addSubview(leaderboardVC.view)
        leaderboardVC.didMove(toParentViewController: self)
        
        view.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "H:|[leaderboardView]|",
                options: NSLayoutFormatOptions(rawValue: 0),
                metrics: nil,
                views: ["leaderboardView": leaderboardVC.view]) +
            NSLayoutConstraint.constraints(
                withVisualFormat: "V:[leaderboardView]|",
                options: NSLayoutFormatOptions(rawValue: 0),
                metrics: nil,
                views: ["leaderboardView": leaderboardVC.view])
        )
        
        view.addConstraints([
            NSLayoutConstraint(
                item: resultViewContainer!,
                attribute: NSLayoutAttribute.centerY,
                relatedBy: NSLayoutRelation.equal,
                toItem: view,
                attribute: NSLayoutAttribute.centerY,
                multiplier: 1.0,
                constant: 0.0),
            NSLayoutConstraint(
                item: leaderboardVC.view,
                attribute: .top,
                relatedBy: .equal,
                toItem: resultViewContainer!,
                attribute: .bottom,
                multiplier: 1.0,
                constant: 0.0
            ),
            NSLayoutConstraint(
                item: resultViewContainer!,
                attribute: NSLayoutAttribute.centerX,
                relatedBy: NSLayoutRelation.equal,
                toItem: view,
                attribute: NSLayoutAttribute.centerX,
                multiplier: 1.0,
                constant: 0.0
            ),
            NSLayoutConstraint(
                item: gameCenterSolicitationLabel!,
                attribute: NSLayoutAttribute.centerX,
                relatedBy: NSLayoutRelation.equal,
                toItem: view,
                attribute: NSLayoutAttribute.centerX,
                multiplier: 1.0,
                constant: 0.0
            ),
            NSLayoutConstraint(
                item: gameCenterSolicitationLabel!,
                attribute: NSLayoutAttribute.bottom,
                relatedBy: NSLayoutRelation.equal,
                toItem: view,
                attribute: NSLayoutAttribute.bottom,
                multiplier: 1.0,
                constant: -5.0 // a little breathing room never hurt nobody
            ),
        ])
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        refreshLayout()
        PlayerIdentityManager.sharedInstance.presentGameCenterLoginViewControllerIfAvailable()
    }
    
    func playerIdentityChanged(_ oldIdentity: PlayerIdentity, newIdentity: PlayerIdentity) {
        if isViewLoaded { refreshLayout() }
    }
    
    func loginViaGameCenterLabelTapped(_ tapRecognizer: UITapGestureRecognizer) {
        UIApplication.shared.openURL(URL(string: "gamecenter:")!)
    }
    
    func refreshLayout() {
        let identity = PlayerIdentityManager.sharedInstance.currentIdentity
        identity.getMyBestScores { usersOldBestScores in
            self.refreshThisGameInfo(usersOldBestScores[self.gameState.levelId])
            identity.recordNewGame(self.gameState) {
                identity.getLeaderboard(self.gameState.levelId, ownForcedScore: self.gameState.finalTime()) { (leaderboard: Leaderboard) -> Void in
                    Analytics.sharedInstance().logEvent(
                        withName: "got_leaderboard",
                        type: AnalyticsEventTypeDebug,
                        attributes: [
                            "current_score": self.gameState.finalTime(),
                            "leaderboard": leaderboard.entries.map() {
                                return [
                                    "rank": $0.rank,
                                    "player_name": $0.playerName,
                                    "score": $0.time
                                ]
                            }
                        ]
                    )
                    self.refreshLeaderboard(identity: identity, leaderboard: leaderboard)
                }
            }
        }
    }
    
    func refreshThisGameInfo(_ oldBestScore: PlayerScore?) {
        let delta = gameState.finalTime() - (oldBestScore?.time ?? gameState.finalTime())
        let deltaAlpha: CGFloat
        let deltaTextColor: UIColor
        if delta != 0 {
            deltaTimeLabel!.text = delta.minuteSecondCentisecondString(true)
            deltaAlpha = 1.0
            deltaTextColor = delta > 0 ? DesignLanguage.NegativeAccentTextColor : DesignLanguage.NeverActiveTextColor
        } else {
            deltaAlpha = 0.0
            deltaTextColor = UIColor.black
        }
        UIView.animate(withDuration: DesignLanguage.MinorAnimationDuration, animations: {
            self.deltaTimeLabel?.alpha = deltaAlpha
            self.deltaTimeLabel?.textColor = deltaTextColor
        }) 
    }
    
    func refreshLeaderboard(identity: PlayerIdentity, leaderboard: Leaderboard) {
        view.layoutIfNeeded()
        
        gameCenterSolicitationLabel?.attributedText = NSAttributedString(
            string: PlayerIdentityManager.sharedInstance.currentIdentity is GameCenterPlayerIdentity ? "See the full leaderboard" : "Log in via Game Center",
            attributes: [
                NSFontAttributeName: UIFont(name: "AvenirNext-Regular", size: 17.5)!,
                NSForegroundColorAttributeName: DesignLanguage.ActiveTextColor,
                NSUnderlineStyleAttributeName: 1,
            ]
        )
        
        UIView.animate(withDuration: DesignLanguage.MinorAnimationDuration, animations: {
            let constraintsToRemove = self.view.constraintsConstrainingView(self.resultViewContainer!) {
                $0 == .top || $0 == .centerY
            }
            self.view.removeConstraints(constraintsToRemove)
            let constraintToAdd: NSLayoutConstraint
            if leaderboard.entries.count > 1 {
                constraintToAdd = NSLayoutConstraint(
                    item: self.resultViewContainer!,
                    attribute: .top,
                    relatedBy: .equal,
                    toItem: self.view,
                    attribute: .top,
                    multiplier: 1.0,
                    constant: self.parent!.topLayoutGuide.length)
            } else {
                constraintToAdd = NSLayoutConstraint(
                    item: self.resultViewContainer!,
                    attribute: NSLayoutAttribute.centerY,
                    relatedBy: NSLayoutRelation.equal,
                    toItem: self.view,
                    attribute: NSLayoutAttribute.centerY,
                    multiplier: 1.0,
                    constant: 0.0
                )
            }
            self.view.addConstraint(constraintToAdd)
            if 2...4 ~= leaderboard.entries.count {
                self.leaderboardVC.setLeaderboard(leaderboard)
            }
            self.view.layoutIfNeeded()
            self.gameCenterSolicitationLabel?.alpha = leaderboard.entries.count <= 1 ? 1.0 : 0.0
            self.leaderboardVC.view.alpha = 2...4 ~= leaderboard.entries.count ? 1.0 : 0.0
        }) 
    }
}
