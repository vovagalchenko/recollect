//
//  LocalPlayerIdentity.swift
//  recollect
//
//  Created by Vova Galchenko on 1/5/15.
//  Copyright (c) 2015 Vova Galchenko. All rights reserved.
//

import Foundation

class LocalPlayerIdentity: PlayerIdentity {
    
    var bestGames: [String: GameState] {
        didSet {
            sync()
        }
    }
    
    init() {
        let scoresFilePath = LocalPlayerIdentity.computeScoresFilePath()
        if NSFileManager.defaultManager().fileExistsAtPath(scoresFilePath) {
            bestGames = NSKeyedUnarchiver.unarchiveObjectWithFile(scoresFilePath) as [String: GameState]
        } else {
            bestGames = [String: GameState]()
        }
    }
    
    private class func computeScoresFilePath() -> String {
        let documentDir = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        return documentDir.stringByAppendingPathComponent("local_player_scores")
    }
    
    func submit(gameState: GameState) -> NSTimeInterval {
        if let bestGameForLevel = bestGames[gameState.levelId] {
            if bestGameForLevel.finalTime() > gameState.finalTime() {
                bestGames[gameState.levelId] = gameState
            }
            return gameState.finalTime() - bestGameForLevel.finalTime()
        } else {
            bestGames[gameState.levelId] = gameState
            return 0.0
        }
    }
    
    func playerId() -> String {
        return "local_player"
    }
    
    func leaderboards(completion: ([PlayerScore]?) -> Void) {
        completion(nil)
    }
    
    private func sync() {
        if NSKeyedArchiver.archiveRootObject(bestGames, toFile: LocalPlayerIdentity.computeScoresFilePath()) {
            NSLog("Wrote local player's best scores successfully:\n\(bestGames)")
        } else {
            NSLog("Failed to write local player's best scores!")
        }
    }
}