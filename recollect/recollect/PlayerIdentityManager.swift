//
//  PlayerIdentityManager.swift
//  recollect
//
//  Created by Vova Galchenko on 1/5/15.
//  Copyright (c) 2015 Vova Galchenko. All rights reserved.
//

import Foundation

class PlayerIdentityManager {
    class func identity() -> PlayerIdentity {
        return LocalPlayerIdentity()
    }
}

protocol PlayerIdentity {
    func submit(gameState: GameState) -> NSTimeInterval
    func playerId() -> String
    func leaderboards(completion: ([PlayerScore]?) -> Void)
}