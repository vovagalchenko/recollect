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
            NSLog("SAVING TO: \(computeScoresFilePath())")
            if NSKeyedArchiver.archiveRootObject(bestGames, toFile: computeScoresFilePath()) {
                NSLog("Wrote local player's best scores successfully:\n\(bestGames)")
            } else {
                Analytics.sharedInstance().logEvent(
                    withName: "local_score_save_fail",
                    type: AnalyticsEventTypeWarning,
                    attributes: nil
                )
            }
            
            NotificationCenter.default.post(
                name: Notification.Name(rawValue: PlayerIdentityManager.BestScoresChangeNotificationName),
                object: self,
                userInfo: nil)
        }
    }
    let playerId: String = "local_player"
    
    init() {
        bestGames = [String: GameState]()
        let scoresFilePath = self.computeScoresFilePath()
        if FileManager.default.fileExists(atPath: scoresFilePath) {
            bestGames = NSKeyedUnarchiver.unarchiveObject(withFile: scoresFilePath) as! [String: GameState]
        }
    }
    
    func computeScoresFilePath() -> String {
        let documentDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] 
        return (documentDir as NSString).appendingPathComponent(playerId + ".scores")
    }
    
    func deltaFromBest(_ game: GameState) -> Foundation.TimeInterval {
        var delta = 0.0
        if let bestTimeForLevel = bestGames[game.levelId]?.finalTime() {
            delta = game.finalTime() - bestTimeForLevel
        }
        return delta
    }
    
    func getLeaderboard(_ levelId: String, ownForcedScore: Foundation.TimeInterval = -1, completion: (Leaderboard) -> Void) {
        var leaderboard = [LeaderboardEntry]()
        if let bestTime = bestGames[levelId]?.finalTime() {
            leaderboard.append(LeaderboardEntry(playerId: playerId, time: bestTime, rank: 1))
        }
        completion(Leaderboard(entries: leaderboard, leaderboardId: levelId))
    }
    
    func getMyBestScores(_ completion: ([String: PlayerScore]) -> Void) {
        var myBestScores = [String: PlayerScore]()
        for (levelId, bestGameState) in bestGames {
            myBestScores[levelId] = PlayerScore(playerId: playerId, time: bestGameState.finalTime())
        }
        completion(myBestScores)
    }
    
    func recordNewGame(_ newGame: GameState, completion: () -> Void) {
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
