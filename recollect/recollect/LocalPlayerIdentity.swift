//
//  LocalPlayerIdentity.swift
//  recollect
//
//  Created by Vova Galchenko on 1/5/15.
//  Copyright (c) 2015 Vova Galchenko. All rights reserved.
//

import Foundation

@objc class LocalPlayerIdentity: PlayerIdentity {
    
    var bestGames: [String: GameState] {
        didSet {
            NSLog("SAVING TO: \(computeScoresFilePath())")
            if NSKeyedArchiver.archiveRootObject(bestGames, toFile: computeScoresFilePath()) {
                NSLog("Wrote local player's best scores successfully:\n\(bestGames)")
            } else {
                logWarning("local_score_save_fail", nil)
            }
            
            NSNotificationCenter.defaultCenter().postNotificationName(
                PlayerIdentityManager.BestScoresChangeNotificationName,
                object: self,
                userInfo: nil)
        }
    }
    let playerId: String = "local_player"
    
    init() {
        bestGames = [String: GameState]()
        let scoresFilePath = self.computeScoresFilePath()
        if NSFileManager.defaultManager().fileExistsAtPath(scoresFilePath) {
            bestGames = NSKeyedUnarchiver.unarchiveObjectWithFile(scoresFilePath) as! [String: GameState]
        }
    }
    
    func computeScoresFilePath() -> String {
        let documentDir = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! String
        return documentDir.stringByAppendingPathComponent(playerId + ".scores")
    }
    
    func deltaFromBest(game: GameState) -> NSTimeInterval {
        var delta = 0.0
        if let bestTimeForLevel = bestGames[game.levelId]?.finalTime() {
            delta = game.finalTime() - bestTimeForLevel
        }
        return delta
    }
    
    func getLeaderboard(levelId: String, completion: Leaderboard -> Void) {
        var leaderboard = [LeaderboardEntry]()
        if let bestTime = bestGames[levelId]?.finalTime() {
            leaderboard.append(LeaderboardEntry(playerId: playerId, time: bestTime, rank: 1))
        }
        completion(Leaderboard(entries: leaderboard, leaderboardId: levelId))
    }
    
    func getMyBestScores(completion: [String: PlayerScore] -> Void) {
        var myBestScores = [String: PlayerScore]()
        for (levelId, bestGameState) in bestGames {
            myBestScores[levelId] = PlayerScore(playerId: playerId, time: bestGameState.finalTime())
        }
        completion(myBestScores)
    }
    
    func recordNewGame(newGame: GameState, completion: () -> Void) {
        if let bestGameForLevel = bestGames[newGame.levelId] {
            if bestGameForLevel.finalTime() > newGame.finalTime() {
                bestGames[newGame.levelId] = newGame
            }
        } else {
            bestGames[newGame.levelId] = newGame
        }
        completion()
    }
}