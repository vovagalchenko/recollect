//
//  GameCenterPlayerIdentity.swift
//  recollect
//
//  Created by Vova Galchenko on 1/24/15.
//  Copyright (c) 2015 Vova Galchenko. All rights reserved.
//

import Foundation
import GameKit

@objc class GameCenterPlayerIdentity: PlayerIdentity {
    let gameKitPlayer: GKPlayer
    let playerId: String
    
    init(gameCenterLocalPlayer: GKPlayer) {
        gameKitPlayer = gameCenterLocalPlayer
        playerId = gameKitPlayer.playerID
    }
    
    private var bestScoreCompletions: [[String: PlayerScore] -> Void] = []
    private var cachedBestScores: [String: PlayerScore]? = nil {
        didSet {
            NSNotificationCenter.defaultCenter().postNotificationName(
                PlayerIdentityManager.BestScoresChangeNotificationName,
                object: self,
                userInfo: nil)
        }
    }
    func getMyBestScores(completion: [String: PlayerScore] -> Void) {
        assert(NSThread.currentThread().isMainThread, "We are relying on getMyBestScores being called on the main thread.")
        if let bestScores = cachedBestScores {
            completion(bestScores)
        } else if bestScoreCompletions.count > 0 {
            bestScoreCompletions.append(completion)
        } else {
            bestScoreCompletions.append(completion)
            var myBestScores = [String: PlayerScore]()
            var levelsToFetch = Set(GameManager.gameLevels)
            for levelId in GameManager.gameLevels {
                let leaderboardRequest = GKLeaderboard(players: [gameKitPlayer])
                leaderboardRequest.identifier = leaderboardIdentifier(levelId)
                leaderboardRequest.loadScoresWithCompletionHandler() { (scores, error) -> Void in
                    if error != nil {
                        NSLog("ERROR ATTEMPTING GETTING MY BEST SCORES:\n\(error)")
                    }
                    let receivedScores = (scores ?? []) as! [GKScore]
                    let playerScore: PlayerScore?
                    if receivedScores.count == 0 {
                        playerScore = nil
                    } else {
                        playerScore = self.gkScoreToPlayerScore(receivedScores[0])
                    }
                    dispatch_async(dispatch_get_main_queue()) {
                        myBestScores[levelId] = playerScore
                        levelsToFetch.remove(levelId)
                        
                        if levelsToFetch.count == 0 {
                            self.cachedBestScores = myBestScores
                            for bestScoreCompletion in self.bestScoreCompletions {
                                self.bestScoreCompletions.removeAtIndex(0)(myBestScores)
                            }
                        }
                    }
                }
            }
        }
    }
    
    func getLeaderboard(levelId: String, completion: Leaderboard -> Void) {
        let leaderboardId = leaderboardIdentifier(levelId)
        let leaderboard = GKLeaderboard()
        leaderboard.identifier = leaderboardId
        leaderboard.range = NSMakeRange(1, 3)
        leaderboard.loadScoresWithCompletionHandler({ (scores: [AnyObject]!, error: NSError!) -> Void in
            if error == nil {
                var needToAddOwnScore = true
                NSLog("GOT \(scores.count) SCORES: \(scores)")
                let playerScores = (scores ?? []).map { s -> LeaderboardEntry in
                    let score = (s as! GKScore)
                    if score.player.playerID == self.gameKitPlayer.playerID {
                        needToAddOwnScore = false
                    }
                    return self.gkScoreToLeaderboardEntry(score)
                }
                if needToAddOwnScore {
                    let myScoreRequest = GKLeaderboard(players: [self.gameKitPlayer])
                    myScoreRequest.identifier = leaderboardId
                    myScoreRequest.loadScoresWithCompletionHandler({ (myScoreArray: [AnyObject]!, error: NSError!) -> Void in
                        NSLog("GOT MY SCORE: \(myScoreArray)")
                        let myScore = ((myScoreArray ?? []) as! [GKScore]).filter { $0.player.playerID == self.gameKitPlayer.playerID }.map {
                            self.gkScoreToLeaderboardEntry($0)
                        }
                        completion(Leaderboard(entries: playerScores + myScore, leaderboardId: leaderboardId))
                    })
                } else {
                    completion(Leaderboard(entries: playerScores, leaderboardId: leaderboardId))
                }
                
            } else {
                NSLog("GAME CENTER ERROR WHILE GETTING LEADERBOARD:\n\(error)")
                completion(Leaderboard(entries: [LeaderboardEntry](), leaderboardId: leaderboardId))
                
            }
        })
    }

    private func gameTimeToScoreValue(gameState: GameState) -> Int64 { return gameTimeToScoreValue(gameState.finalTime()) }
    private func gameTimeToScoreValue(time: NSTimeInterval) -> Int64 { return Int64(round(time*100)) }
    private func gkScoreToLeaderboardEntry(score: GKScore) -> LeaderboardEntry {
        return LeaderboardEntry(
            playerId: score.player.playerID,
            time: NSTimeInterval(score.value)/100.0,
            playerName: score.player.alias,
            rank: score.rank
        )
    }
    private func gkScoreToPlayerScore(score: GKScore) -> PlayerScore {
        return PlayerScore(playerId: score.playerID, time: NSTimeInterval(score.value)/100.0)
    }

    func recordNewGame(newGame: GameState, completion: () -> Void) {
        let leaderboardId = leaderboardIdentifier(newGame.levelId)
        let newScore = GKScore(leaderboardIdentifier: leaderboardId)
        newScore.value = gameTimeToScoreValue(newGame)
        newScore.context = UInt64(newGame.levelId.toInt()!)
        GKScore.reportScores([newScore]) { (error: NSError!) -> Void in
            if error == nil {
                NSLog("SUCCESFULLY REPORTED SCORE: \(newScore)")
            } else {
                NSLog("GAME CENTER ERROR WHILE REPORTING SCORE:\n\(error)")
            }
            self.cachedBestScores = nil
            dispatch_async(dispatch_get_main_queue()) {
                completion()
            }
        }
    }
    
    private func leaderboardIdentifier(levelId: String) -> String { return "level_\(levelId)_time" }
}