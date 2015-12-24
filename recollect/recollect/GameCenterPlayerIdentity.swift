//
//  GameCenterPlayerIdentity.swift
//  recollect
//
//  Created by Vova Galchenko on 1/24/15.
//  Copyright (c) 2015 Vova Galchenko. All rights reserved.
//

import Foundation
import GameKit

@objc class GameCenterPlayerIdentity: NSObject, PlayerIdentity {
    let gameKitPlayer: GKPlayer
    let playerId: String
    
    init(gameCenterLocalPlayer: GKPlayer) {
        gameKitPlayer = gameCenterLocalPlayer
        playerId = gameKitPlayer.playerID!
        super.init()
        
        GameManager.sharedInstance.subscribeToGameStateChangeNotifications(self)
        
        Analytics.sharedInstance().logEventWithName(
            "game_center_authenticated",
            type: AnalyticsEventTypeAppLifecycle,
            attributes: ["player_id": playerId, "player_username": gameKitPlayer.description]
        )
    }
    
    deinit {
        GameManager.sharedInstance.unsubscribeFromGameStateChangeNotifications(self)
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
                    if let emittedError = error  {
                        Analytics.sharedInstance().logEventWithName(
                            "game_center_best_score_fetch_error",
                            type: AnalyticsEventTypeWarning,
                            attributes: ["error": emittedError.description]
                        )
                    }
                    let receivedScores = (scores ?? []) 
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
                            for _ in self.bestScoreCompletions {
                                self.bestScoreCompletions.removeAtIndex(0)(myBestScores)
                            }
                        }
                    }
                }
            }
        }
    }
    
    func getLeaderboard(levelId: String, ownForcedScore: NSTimeInterval = -1, completion: Leaderboard -> Void) {
        let leaderboardId = leaderboardIdentifier(levelId)
        let leaderboard = GKLeaderboard()
        leaderboard.identifier = leaderboardId
        leaderboard.range = NSMakeRange(1, 3)
        leaderboard.loadScoresWithCompletionHandler({ (scores: [GKScore]?, error: NSError?) -> Void in
            if error == nil {
                var needToAddOwnScore = true
                let playerScores = (scores ?? []).map { s -> LeaderboardEntry in
                    if s.player.playerID == self.gameKitPlayer.playerID {
                        needToAddOwnScore = false
                    }
                    return self.gkScoreToLeaderboardEntry(s)
                }
                let sortResultAndCallCompletion = { (entries: [LeaderboardEntry]) -> Void in
                    // All of this acrobatics is necessary because the game center might not return the score we just submitted... what a piece of shit
                    let sortedEntries: [LeaderboardEntry]
                    if ownForcedScore != -1 {
                        let scoreToAttemptForce = ownForcedScore
                        var forcedEntry: LeaderboardEntry? = nil
                        let entriesWithForcedScore: [LeaderboardEntry] = entries
                            .map() {
                                if $0.playerId == self.playerId && scoreToAttemptForce < $0.time {
                                    forcedEntry = LeaderboardEntry(
                                        playerId: $0.playerId,
                                        time: scoreToAttemptForce,
                                        playerName: $0.playerName,
                                        rank: $0.rank
                                    )
                                    return forcedEntry!
                                } else {
                                    return $0
                                }
                            }
                            .sort() { $0.rank <= $1.rank }
                        
                        if let successfullyForcedEntry = forcedEntry {
                            var finalEntries = [LeaderboardEntry]()
                            var inserted = false
                            for orderedEntry in entriesWithForcedScore {
                                if orderedEntry.rank <= successfullyForcedEntry.rank && orderedEntry.time > successfullyForcedEntry.time {
                                    finalEntries.append(LeaderboardEntry(
                                        playerId: successfullyForcedEntry.playerId,
                                        time: successfullyForcedEntry.time,
                                        playerName: successfullyForcedEntry.playerName,
                                        rank: orderedEntry.rank
                                    ))
                                    inserted = true
                                }
                                
                                if orderedEntry.playerId == successfullyForcedEntry.playerId {
                                    if !inserted {
                                        finalEntries.append(orderedEntry)
                                    }
                                } else if inserted && orderedEntry.rank < successfullyForcedEntry.rank {
                                    finalEntries.append(LeaderboardEntry(
                                        playerId: orderedEntry.playerId,
                                        time: orderedEntry.time,
                                        playerName: orderedEntry.playerName,
                                        rank: orderedEntry.rank + 1
                                    ))
                                } else {
                                    finalEntries.append(orderedEntry)
                                }
                            }
                            sortedEntries = finalEntries
                        } else {
                            sortedEntries = entries
                        }
                    } else {
                        sortedEntries = entries
                    }
                    completion(Leaderboard(entries: sortedEntries, leaderboardId: leaderboardId))
                }
                if needToAddOwnScore {
                    let myScoreRequest = GKLeaderboard(players: [self.gameKitPlayer])
                    myScoreRequest.identifier = leaderboardId
                    myScoreRequest.loadScoresWithCompletionHandler({ (myScoreArray: [GKScore]?, error: NSError?) -> Void in
                        let myScore = ((myScoreArray ?? []) ).filter { $0.player.playerID == self.gameKitPlayer.playerID }.map {
                            self.gkScoreToLeaderboardEntry($0)
                        }
                        sortResultAndCallCompletion(playerScores + myScore)
                    })
                } else {
                    sortResultAndCallCompletion(playerScores)
                }
                
            } else {
                Analytics.sharedInstance().logEventWithName(
                    "game_center_leaderboard_fetch_error",
                    type: AnalyticsEventTypeWarning,
                    attributes: ["error": error!.description]
                )
                completion(Leaderboard(entries: [LeaderboardEntry](), leaderboardId: leaderboardId))
                
            }
        })
    }

    private func gameTimeToScoreValue(gameState: GameState) -> Int64 { return gameTimeToScoreValue(gameState.finalTime()) }
    private func gameTimeToScoreValue(time: NSTimeInterval) -> Int64 { return Int64(round(time*100)) }
    private func gkScoreToLeaderboardEntry(score: GKScore) -> LeaderboardEntry {
        return LeaderboardEntry(
            playerId: score.player.playerID!,
            time: NSTimeInterval(score.value)/100.0,
            playerName: score.player.alias ?? "",
            rank: score.rank
        )
    }
    private func gkScoreToPlayerScore(score: GKScore) -> PlayerScore {
        return PlayerScore(playerId: score.player.playerID!, time: NSTimeInterval(score.value)/100.0)
    }

    func recordNewGame(newGame: GameState, completion: () -> Void) {
        let leaderboardId = leaderboardIdentifier(newGame.levelId)
        let newScore = GKScore(leaderboardIdentifier: leaderboardId)
        newScore.value = gameTimeToScoreValue(newGame)
        newScore.context = UInt64(Int(newGame.levelId)!)
        GKScore.reportScores([newScore]) { (error: NSError?) -> Void in
            if error == nil {
                NSLog("SUCCESFULLY REPORTED SCORE: \(newScore)")
                Analytics.sharedInstance().logEventWithName(
                    "game_center_score_report",
                    type: AnalyticsEventTypeDebug,
                    attributes: ["final_time": newGame.finalTime(), "level": newGame.levelId]
                )
            } else {
                Analytics.sharedInstance().logEventWithName(
                    "game_center_score_report_error",
                    type: AnalyticsEventTypeWarning,
                    attributes: ["error": error?.description ?? "unknown_error"]
                )
            }
            self.cachedBestScores = nil
            completion()
        }
    }
    
    private func leaderboardIdentifier(levelId: String) -> String { return "level_\(levelId)_time" }
}

extension GameCenterPlayerIdentity: GameStateChangeListener {
    func gameStateChanged(change: GameStateChange) {
        if change.newGameState?.isFinished() ?? false {
            let levelClearedAchievement = GKAchievement(
                identifier: "level_\(change.newGameState!.levelId)_cleared",
                player: gameKitPlayer
            )
            levelClearedAchievement.percentComplete = 100.0
            let achievementsToReport: [GKAchievement]
            if change.newGameState!.isFlawless() {
                let flawlessAchievement = GKAchievement(
                    identifier: "level_\(change.newGameState!.levelId)_cleared_flawlessly",
                    player: gameKitPlayer
                )
                flawlessAchievement.showsCompletionBanner = true
                flawlessAchievement.percentComplete = 100.0
                achievementsToReport = [
                    levelClearedAchievement,
                    flawlessAchievement
                ]
            } else {
                achievementsToReport = [levelClearedAchievement]
            }
            
            GKAchievement.reportAchievements(achievementsToReport) { error -> Void in
                if error != nil {
                    Analytics.sharedInstance().logEventWithName(
                        "game_center_achievement_report_error",
                        type: AnalyticsEventTypeWarning,
                        attributes: ["error": error?.description ?? "unexplained_error"]
                    )
                } else {
                    let achievementIds = achievementsToReport.map { $0.identifier! }
                    Analytics.sharedInstance().logEventWithName(
                        "game_center_achievement_report",
                        type: AnalyticsEventTypeDebug,
                        attributes: ["achievements": achievementIds]
                    )
                    NSLog("Reported achievements \(achievementsToReport)")
                }
            }
        }
    }
}