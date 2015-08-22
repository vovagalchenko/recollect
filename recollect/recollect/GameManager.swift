//
//  GameManager.swift
//  recollect
//
//  Created by Vova Galchenko on 12/29/14.
//  Copyright (c) 2014 Vova Galchenko. All rights reserved.
//

import Foundation
import UIKit

class GameManager: GameplayInputControllerDelegate {
    
    class var sharedInstance : GameManager {
        struct Static {
            static let instance : GameManager = GameManager()
        }
        return Static.instance
    }
    
    class var gameLevels: [String] {
        return ["1", "2", "3", "4", "5"]
    }
    
    class var GameStateChangeNotificationName: String {
        return "GAME_STATE_CHANGED"
    }
    
    class var GameStateChangeUserInfoKey: NSString {
        return "change"
    }
    
    class var penaltyPerPeek: NSTimeInterval {
        return 5
    }
    
    var currentGameState: GameState? {
        didSet {
            let logEventAttributes: [NSObject: AnyObject]
            if let newGs = currentGameState {
                logEventAttributes = [
                    "no_game": false,
                    "level": newGs.levelId,
                    "time_start": newGs.latestTimeStart?.description ?? "nil",
                    "time_so_far": newGs.time(),
                    "peeks": newGs.peeks.map({ $0.description }),
                    "is_finished": newGs.isFinished(),
                    "is_flawless": newGs.isFlawless(),
                    "challenges": newGs.challenges.map({ "\($0)" })
                ]
            } else {
                logEventAttributes = ["no_game": true]
            }
            Analytics.sharedInstance().logEventWithName(
                "curr_game_state_change",
                type: AnalyticsEventTypeDebug,
                attributes: logEventAttributes
            )
            
            NSNotificationCenter.defaultCenter().postNotificationName(
                GameManager.GameStateChangeNotificationName,
                object: self,
                userInfo: [GameManager.GameStateChangeUserInfoKey: GameStateChange(oldGameState: oldValue, newGameState: currentGameState)])
        }
    }
    
    init() {
        NSNotificationCenter
            .defaultCenter()
            .addObserver(self, selector: "appDidEnterBackground:", name: UIApplicationDidEnterBackgroundNotification, object: nil)
    }
    
    @objc private func appDidEnterBackground(notification: NSNotification) {
        if currentGameState != nil && !currentGameState!.isFinished() {
            currentGameState = nil
        }
    }
    
    func startGame(gameLevelId: String) {
        assert(self.currentGameState == nil || self.currentGameState!.latestTimeStart == nil, "Can't start a game when one is already in progress!")
        self.currentGameState = GameState(n: gameLevelId.toInt()!, numRounds: 10)
    }
    
    func subscribeToGameStateChangeNotifications(listener: GameStateChangeListener) {
        NSNotificationCenter.defaultCenter().addObserver(
            listener,
            selector: "gameStateChangeNotificationReceived:",
            name: GameManager.GameStateChangeNotificationName,
            object: self)
    }
    
    func unsubscribeFromGameStateChangeNotifications(listener: GameStateChangeListener) {
        NSNotificationCenter.defaultCenter().removeObserver(listener, name: GameManager.GameStateChangeNotificationName, object: self)
    }
}

extension GameManager: GameplayOutputViewControllerDelegate {
    func peeked() {
        assert(self.currentGameState != nil, "Can't add a peek, because there's no game in progress!")
        Analytics.sharedInstance().logEventWithName(
            "peek",
            type: AnalyticsEventTypeUserAction,
            attributes: nil
        )
        currentGameState = currentGameState!.addPeek()
    }
}

extension GameManager: GameplayInputControllerDelegate {
    func receivedInput(input: GameplayInput) {
        Analytics.sharedInstance().logEventWithName(
            "gameplay_input",
            type: AnalyticsEventTypeUserAction,
            attributes: ["value": input.description]
        )
        switch input {
            case GameplayInput.Back:
                currentGameState = nil
            case GameplayInput.Forward:
                currentGameState = currentGameState!.advance()
            case .Zero, .One, .Two, .Three, .Four, .Five, .Six, .Seven, .Eight, .Nine:
                if currentGameState?.currentChallengeIndex >= 0 && currentGameState?.currentChallengeIndex < currentGameState?.challenges.count {
                    currentGameState = currentGameState!.advance(userInput: input.rawValue)
                }
            default:
                fatalError("Can't understand user input <\(input)>.")
        }
    }
}

extension GameManager: LevelPickerViewControllerDelegate {
    func pickedLevel(levelId: String) {
        startGame(levelId)
    }
}

extension GameManager: SharingViewControllerDelegate {
    func repeatButtonPressed(sharingVC: SharingViewController) {
        if let levelId = currentGameState?.levelId {
            startGame(levelId)
        } else {
            fatalError("Repeat button pressed when there isn't a game that just finished!")
        }
    }
    
    func menuButtonPressed(sharingVC: SharingViewController) {
        currentGameState = nil
    }
}

@objc protocol GameStateChangeListener {
    func gameStateChanged(change: GameStateChange)
    func gameStateChangeNotificationReceived(notification: NSNotification!)
}

extension NSObject {
    func gameStateChangeNotificationReceived(notification: NSNotification!) {
        let change = notification!.userInfo![GameManager.GameStateChangeUserInfoKey]! as! GameStateChange
        if let gameChangeListener = self as? GameStateChangeListener {
            gameChangeListener.gameStateChanged(change)
        }
    }
}