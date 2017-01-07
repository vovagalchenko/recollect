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
        view.backgroundColor = UIColor.clear
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(LeaderboardViewController.handleTap(_:)))
        view.addGestureRecognizer(tapRecognizer)
    }
    
    func setLeaderboard(_ leaderboard: Leaderboard) {
        assert(2...4 ~= leaderboard.entries.count, "Leaderboards must have lengths between 2 and 4.")
        
        currentLeaderboard = leaderboard
        for subview in view.subviews { subview.removeFromSuperview() }
        view.removeConstraints(view.constraints)
        
        var leaderboardEntryViews = [LeaderboardEntryView]()
        for (index, entry) in leaderboard.entries.enumerated() {
            let position: LeaderboardEntryViewPosition
            if index == 0 {
                position = .top
            } else if index == leaderboard.entries.count - 1 {
                position = .bottom
            } else {
                position = .middle
            }
            let entryView = LeaderboardEntryView(pos: position)
            entryView.setLeaderboardEntry(entry)
            view.addSubview(entryView)
            view.addConstraints(
                NSLayoutConstraint.constraints(
                    withVisualFormat: "H:|[entry]|",
                    options: NSLayoutFormatOptions(rawValue: 0),
                    metrics: nil,
                    views: ["entry": entryView])
            )
            if let existingPrevEntryView = leaderboardEntryViews.last {
                let viewToStickTo: UIView
                if existingPrevEntryView.rank < entry.rank - 1 {
                    let gapEntryView = LeaderboardEntryView(pos: .gap)
                    view.addSubview(gapEntryView)
                    view.addConstraints(
                        NSLayoutConstraint.constraints(
                            withVisualFormat: "H:|[entry]|",
                            options: NSLayoutFormatOptions(rawValue: 0),
                            metrics: nil,
                            views: ["entry": gapEntryView]) +
                        [
                            NSLayoutConstraint(
                                item: gapEntryView,
                                attribute: .height,
                                relatedBy: .equal,
                                toItem: existingPrevEntryView,
                                attribute: .height,
                                multiplier: 0.5,
                                constant: 0.0),
                            NSLayoutConstraint(
                                item: gapEntryView,
                                attribute: .top,
                                relatedBy: .equal,
                                toItem: existingPrevEntryView,
                                attribute: .bottom,
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
                        attribute: .height,
                        relatedBy: .equal,
                        toItem: existingPrevEntryView,
                        attribute: .height,
                        multiplier: 1.0,
                        constant: 0.0),
                    NSLayoutConstraint(
                        item: entryView,
                        attribute: .top,
                        relatedBy: .equal,
                        toItem: viewToStickTo,
                        attribute: .bottom,
                        multiplier: 1.0,
                        constant: 0.0)
                ])
            } else {
                view.addConstraint(
                    NSLayoutConstraint(
                        item: entryView,
                        attribute: .top,
                        relatedBy: .equal,
                        toItem: view,
                        attribute: .top,
                        multiplier: 1.0,
                        constant: 0.0)
                )
            }
            if index == leaderboard.entries.count - 1 {
                view.addConstraint(
                    NSLayoutConstraint(
                        item: entryView,
                        attribute: .bottom,
                        relatedBy: .equal,
                        toItem: view,
                        attribute: .bottom,
                        multiplier: 1.0,
                        constant: 0.0)
                )
            }
            leaderboardEntryViews.append(entryView)
        }
        
        let playerIds = leaderboard.entries.map { $0.playerId }
        GKPlayer.loadPlayers(forIdentifiers: playerIds) { (players, error) -> Void in
            if let existingPlayers = players {
                existingPlayers.forEach { player -> Void in
                    player.loadPhoto(forSize: GKPhotoSizeNormal) { (image, error) -> Void in
                        if let existingImage = image {
                            leaderboardEntryViews
                                .filter { $0.playerId == player.playerID }
                                .forEach { $0.setAvatarImage(existingImage) }
                        } else {
                            Analytics.sharedInstance()
                                .logEvent(
                                    withName: "player_avatar_load_fail",
                                    type: AnalyticsEventTypeWarning,
                                    attributes: [
                                        "player_id": player.playerID ?? "unknown_player_id",
                                        "error": error?.localizedDescription ?? "unknown_error"
                                    ]
                            )
                        }
                    }
                }
            } else {
                Analytics.sharedInstance()
                    .logEvent(
                        withName: "player_for_id_load_fail",
                        type: AnalyticsEventTypeWarning,
                        attributes: [
                            "player_ids": playerIds.description,
                            "error": error?.localizedDescription ?? "unknown_error"
                        ]
                )
            }
        }
    }
    
    @objc private func handleTap(_ tapRecognizer: UITapGestureRecognizer) {
        if let leaderboard = currentLeaderboard {
            let nativeLeaderboardVc = GKGameCenterViewController()
            nativeLeaderboardVc.gameCenterDelegate = self
            nativeLeaderboardVc.viewState = .leaderboards
            nativeLeaderboardVc.leaderboardIdentifier = leaderboard.leaderboardId
            present(nativeLeaderboardVc, animated: true, completion: nil)
        }
    }
    
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        dismiss(animated: true, completion: nil)
    }
}
