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
    var rank: Int?
    
    init(playerId: String, time: NSTimeInterval, rank: Int? = nil) {
        self.playerId = playerId
        self.time = time
        self.rank = rank
    }
}
