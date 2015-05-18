//
//  Leaderboard.swift
//  recollect
//
//  Created by Vova Galchenko on 1/5/15.
//  Copyright (c) 2015 Vova Galchenko. All rights reserved.
//

import Foundation

class PlayerScore {
    let playerId: String
    let time: NSTimeInterval
    
    init(playerId: String, time: NSTimeInterval) {
        self.playerId = playerId
        self.time = time
    }
}

class LeaderboardEntry: PlayerScore {
    let playerName: String
    let rank: Int
    
    init(playerId: String, time: NSTimeInterval, playerName: String = "You", rank: Int) {
        self.playerName = playerName
        self.rank = rank
        super.init(playerId: playerId, time: time)
    }
}

@objc class Leaderboard {
    let entries: [LeaderboardEntry]
    let leaderboardId: String
    
    init(entries: [LeaderboardEntry], leaderboardId: String) {
        self.entries = entries
        self.leaderboardId = leaderboardId
    }
}