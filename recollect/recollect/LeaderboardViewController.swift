//
//  LeaderboardViewController.swift
//  recollect
//
//  Created by Vova Galchenko on 5/17/15.
//  Copyright (c) 2015 Vova Galchenko. All rights reserved.
//

import UIKit
import GameKit

class LeaderboardViewController: UIViewController, GKGameCenterControllerDelegate {
    var currentLeaderboard: Leaderboard?
    
    override func viewDidLoad() {
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.clearColor()
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: "handleTap:")
        view.addGestureRecognizer(tapRecognizer)
    }
    
    func setLeaderboard(leaderboard: Leaderboard) {
        assert(2...4 ~= leaderboard.entries.count, "Leaderboards must have lengths between 2 and 4.")
        
        currentLeaderboard = leaderboard
        for subview in view.subviews { subview.removeFromSuperview() }
        view.removeConstraints(view.constraints)
        
        var leaderboardEntryViews = [LeaderboardEntryView]()
        for (index, entry) in leaderboard.entries.enumerate() {
            let position: LeaderboardEntryViewPosition
            if index == 0 {
                position = .Top
            } else if index == leaderboard.entries.count - 1 {
                position = .Bottom
            } else {
                position = .Middle
            }
            let entryView = LeaderboardEntryView(pos: position)
            entryView.setLeaderboardEntry(entry)
            view.addSubview(entryView)
            view.addConstraints(
                NSLayoutConstraint.constraintsWithVisualFormat(
                    "H:|[entry]|",
                    options: NSLayoutFormatOptions(rawValue: 0),
                    metrics: nil,
                    views: ["entry": entryView])
            )
            if let existingPrevEntryView = leaderboardEntryViews.last {
                let viewToStickTo: UIView
                if existingPrevEntryView.rank < entry.rank - 1 {
                    let gapEntryView = LeaderboardEntryView(pos: .Gap)
                    view.addSubview(gapEntryView)
                    view.addConstraints(
                        NSLayoutConstraint.constraintsWithVisualFormat(
                            "H:|[entry]|",
                            options: NSLayoutFormatOptions(rawValue: 0),
                            metrics: nil,
                            views: ["entry": gapEntryView]) +
                        [
                            NSLayoutConstraint(
                                item: gapEntryView,
                                attribute: .Height,
                                relatedBy: .Equal,
                                toItem: existingPrevEntryView,
                                attribute: .Height,
                                multiplier: 0.5,
                                constant: 0.0),
                            NSLayoutConstraint(
                                item: gapEntryView,
                                attribute: .Top,
                                relatedBy: .Equal,
                                toItem: existingPrevEntryView,
                                attribute: .Bottom,
                                multiplier: 1.0,
                                constant: 0.0)
                        ]
                    )
                    viewToStickTo = gapEntryView
                } else {
                    viewToStickTo = existingPrevEntryView
                }
                view.addConstraints([
                    NSLayoutConstraint(
                        item: entryView,
                        attribute: .Height,
                        relatedBy: .Equal,
                        toItem: existingPrevEntryView,
                        attribute: .Height,
                        multiplier: 1.0,
                        constant: 0.0),
                    NSLayoutConstraint(
                        item: entryView,
                        attribute: .Top,
                        relatedBy: .Equal,
                        toItem: viewToStickTo,
                        attribute: .Bottom,
                        multiplier: 1.0,
                        constant: 0.0)
                ])
            } else {
                view.addConstraint(
                    NSLayoutConstraint(
                        item: entryView,
                        attribute: .Top,
                        relatedBy: .Equal,
                        toItem: view,
                        attribute: .Top,
                        multiplier: 1.0,
                        constant: 0.0)
                )
            }
            if index == leaderboard.entries.count - 1 {
                view.addConstraint(
                    NSLayoutConstraint(
                        item: entryView,
                        attribute: .Bottom,
                        relatedBy: .Equal,
                        toItem: view,
                        attribute: .Bottom,
                        multiplier: 1.0,
                        constant: 0.0)
                )
            }
            leaderboardEntryViews.append(entryView)
        }
        
        let playerIds = leaderboard.entries.map { $0.playerId }
        GKPlayer.loadPlayersForIdentifiers(playerIds) { (players, error) -> Void in
            if let existingPlayers = players {
                existingPlayers.forEach { player -> Void in
                    player.loadPhotoForSize(GKPhotoSizeNormal) { (image, error) -> Void in
                        if let existingImage = image {
                            leaderboardEntryViews
                                .filter { $0.playerId == player.playerID }
                                .forEach { $0.setAvatarImage(existingImage) }
                        } else {
                            Analytics.sharedInstance()
                                .logEventWithName(
                                    "player_avatar_load_fail",
                                    type: AnalyticsEventTypeWarning,
                                    attributes: [
                                        "player_id": player.playerID ?? "unknown_player_id",
                                        "error": error?.description ?? "unknown_error"
                                    ]
                            )
                        }
                    }
                }
            } else {
                Analytics.sharedInstance()
                    .logEventWithName(
                        "player_for_id_load_fail",
                        type: AnalyticsEventTypeWarning,
                        attributes: [
                            "player_ids": playerIds.description,
                            "error": error?.description ?? "unknown_error"
                        ]
                )
            }
        }
    }
    
    @objc private func handleTap(tapRecognizer: UITapGestureRecognizer) {
        if let leaderboard = currentLeaderboard {
            let nativeLeaderboardVc = GKGameCenterViewController()
            nativeLeaderboardVc.gameCenterDelegate = self
            nativeLeaderboardVc.viewState = .Leaderboards
            nativeLeaderboardVc.leaderboardIdentifier = leaderboard.leaderboardId
            presentViewController(nativeLeaderboardVc, animated: true, completion: nil)
        }
    }
    
    func gameCenterViewControllerDidFinish(gameCenterViewController: GKGameCenterViewController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
