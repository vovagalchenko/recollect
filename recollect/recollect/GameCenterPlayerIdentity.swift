//
//  GameCenterPlayerIdentity.swift
//  recollect
//
//  Created by Vova Galchenko on 1/24/15.
//  Copyright (c) 2015 Vova Galchenko. All rights reserved.
//

import Foundation
import GameKit

class GameCenterPlayerIdentity: PlayerIdentity {
    let gameKitPlayer: GKPlayer
    override var playerId: String {
        return gameKitPlayer.playerID ?? NSUUID().UUIDString
    }
    init(gameCenterLocalPlayer: GKPlayer) {
        gameKitPlayer = gameCenterLocalPlayer
    }
    
    override func getLeaderboard(gameState: GameState, completion: ([PlayerScore]) -> Void) {
        let leaderboardId = leaderboardIdentifier(gameState)
        let leaderboard = GKLeaderboard()
        leaderboard.identifier = leaderboardId
        leaderboard.range = NSMakeRange(1, 3)
        let callCompletion = { (gameCenterScores: [PlayerScore]) -> Void in
            if gameCenterScores.count > 0 {
                completion(gameCenterScores)
            } else {
                var leaderboard = [PlayerScore]()
                if let bestTime = self.bestGames[gameState.levelId]?.finalTime() {
                    leaderboard.append(PlayerScore(playerId: self.playerId, time: bestTime, rank: 1))
                }
                completion(leaderboard)
            }
            
        }
        leaderboard.loadScoresWithCompletionHandler({ (scores: [AnyObject]!, error: NSError!) -> Void in
            if error == nil {
                var needToAddOwnScore = true
                NSLog("GOT SCORES: \(scores)")
                let playerScores = (scores ?? []).map { s -> PlayerScore in
                    let score = (s as! GKScore)
                    if score.player.playerID == self.gameKitPlayer.playerID {
                        needToAddOwnScore = false
                    }
                    return self.gkScoreToPlayerScore(score)
                }
                if needToAddOwnScore {
                    let myScoreRequest = GKLeaderboard(players: [self.gameKitPlayer])
                    myScoreRequest.identifier = leaderboardId
                    myScoreRequest.loadScoresWithCompletionHandler({ (myScoreArray: [AnyObject]!, error: NSError!) -> Void in
                        let myScore = ((myScoreArray ?? []) as! [GKScore]).filter { $0.player.playerID == self.gameKitPlayer.playerID }.map { self.gkScoreToPlayerScore($0) }
                        completion(playerScores + myScore)
                    })
                } else {
                    completion(playerScores)
                }
                
            } else {
                NSLog("GAME CENTER ERROR WHILE GETTING LEADERBOARD:\n\(error)")
                var leaderboard = [PlayerScore]()
                if let bestTime = self.bestGames[gameState.levelId]?.finalTime() {
                    leaderboard.append(PlayerScore(playerId: self.playerId, time: bestTime, rank: 1))
                }
                completion(leaderboard)
            }
        })
    }

    private func gameTimeToScoreValue(gameState: GameState) -> Int64 { return Int64(round(gameState.finalTime()*100)) }
    private func gkScoreToPlayerScore(score: GKScore) -> PlayerScore {
        return PlayerScore(
            playerId: score.player.playerID,
            time: NSTimeInterval(score.value)/100.0,
            rank: score.rank
        )
    }

    override func flushBestGames(newGame: GameState) {
        super.flushBestGames(newGame)
        let leaderboardId = leaderboardIdentifier(newGame)
        let newScore = GKScore(leaderboardIdentifier: leaderboardId)
        newScore.value = gameTimeToScoreValue(newGame)
        GKScore.reportScores([newScore]) { (error: NSError!) -> Void in
            if error == nil {
                NSLog("SUCCESFULLY REPORTED SCORE: \(newScore)")
            } else {
                NSLog("GAME CENTER ERROR WHILE REPORTING SCORE:\n\(error)")
            }
        }
    }
    
    private func leaderboardIdentifier(gameState: GameState) -> String { return "level_\(gameState.levelId)_time" }
}