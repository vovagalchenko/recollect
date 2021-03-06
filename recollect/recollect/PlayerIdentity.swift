//
//  PlayerIdentity.swift
//  recollect
//
//  Created by Vova Galchenko on 4/17/15.
//  Copyright (c) 2015 Vova Galchenko. All rights reserved.
//

import Foundation

protocol PlayerIdentity: class {
    var playerId: String { get }
    func getLeaderboard(_ levelId: String, ownForcedScore: Foundation.TimeInterval, completion: @escaping (Leaderboard) -> Void)
    func recordNewGame(_ newGame: GameState, completion: @escaping () -> Void) // <-- best effort, could be done asynchronously
    func getMyBestScores(_ completion: @escaping ([String: PlayerScore]) -> Void)
}
