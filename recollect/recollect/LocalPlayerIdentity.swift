//
//  LocalPlayerIdentity.swift
//  recollect
//
//  Created by Vova Galchenko on 1/5/15.
//  Copyright (c) 2015 Vova Galchenko. All rights reserved.
//

import Foundation

class LocalPlayerIdentity: PlayerIdentity {
    
    class var BestScoreChangeNotificationName: String { return "BEST_SCORE_CHANGED" }
    
    var bestGames: [String: GameState] {
        didSet {
            sync()
            NSNotificationCenter.defaultCenter().postNotificationName(
                LocalPlayerIdentity.BestScoreChangeNotificationName,
                object: self,
                userInfo: nil)
        }
    }
    let playerId = "local_player"
    
    init() {
        bestGames = [String: GameState]()
        let scoresFilePath = self.computeScoresFilePath()
        if NSFileManager.defaultManager().fileExistsAtPath(scoresFilePath) {
            bestGames = NSKeyedUnarchiver.unarchiveObjectWithFile(scoresFilePath) as [String: GameState]
        }
    }
    
    func computeScoresFilePath() -> String {
        let documentDir = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        return documentDir.stringByAppendingPathComponent(playerId + ".scores")
    }
    
    func deltaFromBest(game: GameState) -> NSTimeInterval {
        var delta = 0.0
        if let bestTimeForLevel = bestGames[game.levelId]?.finalTime() {
            delta = game.finalTime() - bestTimeForLevel
        }
        return delta
    }
    
    func submit(gameState: GameState, completion: ([PlayerScore]) -> Void) {
        var leaderboard = [PlayerScore]()
        if let bestTime = bestGames[gameState.levelId]?.finalTime() {
            leaderboard.append(PlayerScore(playerId: playerId, time: bestTime, rank: 1))
        }
        completion(leaderboard)
    }
    
    func flushBestGames(newGame: GameState) {
        if let bestGameForLevel = bestGames[newGame.levelId] {
            if bestGameForLevel.finalTime() > newGame.finalTime() {
                bestGames[newGame.levelId] = newGame
            }
        } else {
            bestGames[newGame.levelId] = newGame
        }
    }
    
    func bestTime(levelId: String) -> NSTimeInterval? {
        return bestGames[levelId]?.finalTime()
    }
    
    private func sync() {
        if NSKeyedArchiver.archiveRootObject(bestGames, toFile: computeScoresFilePath()) {
            NSLog("Wrote local player's best scores successfully:\n\(bestGames)")
        } else {
            NSLog("Failed to write local player's best scores!")
        }
    }
}