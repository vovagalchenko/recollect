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
    var playerId: String { get }
    func deltaFromBest(game: GameState) -> NSTimeInterval
    func submit(gameState: GameState, completion: ([PlayerScore]) -> Void)
    func flushBestGames(newGame: GameState)
    func bestTime(levelId: String) -> NSTimeInterval?
    func finishedLevelBefore(levelId: String) -> Bool
}