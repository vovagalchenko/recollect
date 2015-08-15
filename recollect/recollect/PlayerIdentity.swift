//
//  PlayerIdentity.swift
//  recollect
//
//  Created by Vova Galchenko on 4/17/15.
//  Copyright (c) 2015 Vova Galchenko. All rights reserved.
//

import Foundation

@objc protocol PlayerIdentity {
    var playerId: String { get }
    func getLeaderboard(levelId: String, ownForcedScore: NSTimeInterval, completion: Leaderboard -> Void)
    func recordNewGame(newGame: GameState, completion: () -> Void) // <-- best effort, could be done asynchronously
    func getMyBestScores(completion: [String: PlayerScore] -> Void)
}