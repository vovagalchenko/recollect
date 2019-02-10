//
//  GameManager.swift
//  recollect
//
//  Created by Vova Galchenko on 12/29/14.
//  Copyright (c) 2014 Vova Galchenko. All rights reserved.
//

import Foundation
import UIKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
private func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
private func >= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l >= r
  default:
    return !(lhs < rhs)
  }
}


class GameManager {
    
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
    
    class var penaltyPerPeek: Foundation.TimeInterval {
        return 5
    }
    
    var currentGameState: GameState? {
        didSet {
            let logEventAttributes: [AnyHashable: Any]
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
            Analytics.sharedInstance().logEvent(
                withName: "curr_game_state_change",
                type: AnalyticsEventTypeDebug,
                attributes: logEventAttributes
            )
            
            NotificationCenter.default.post(
                name: Notification.Name(rawValue: GameManager.GameStateChangeNotificationName),
                object: self,
                userInfo: [GameManager.GameStateChangeUserInfoKey: GameStateChange(oldGameState: oldValue, newGameState: currentGameState)])
        }
    }
    
    init() {
        NotificationCenter.default
            .addObserver(self, selector: #selector(GameManager.appDidEnterBackground(_:)), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    @objc private func appDidEnterBackground(_ notification: Notification) {
        if currentGameState != nil && !currentGameState!.isFinished() {
            currentGameState = nil
        }
    }
    
    func startGame(_ gameLevelId: String) {
        assert(self.currentGameState == nil || self.currentGameState!.latestTimeStart == nil, "Can't start a game when one is already in progress!")
        self.currentGameState = GameState(n: Int(gameLevelId)!, numRounds: 10)
    }
    
    func subscribeToGameStateChangeNotifications(_ listener: GameStateChangeListener) {
        NotificationCenter.default.addObserver(
            listener,
            selector: #selector(NSObject.gameStateChangeNotificationReceived(_:)),
            name: NSNotification.Name(rawValue: GameManager.GameStateChangeNotificationName),
            object: self)
    }
    
    func unsubscribeFromGameStateChangeNotifications(_ listener: GameStateChangeListener) {
        NotificationCenter.default.removeObserver(listener, name: NSNotification.Name(rawValue: GameManager.GameStateChangeNotificationName), object: self)
    }
}

extension GameManager: GameplayOutputViewControllerDelegate {
    func peeked() {
        assert(self.currentGameState != nil, "Can't add a peek, because there's no game in progress!")
        Analytics.sharedInstance().logEvent(
            withName: "peek",
            type: AnalyticsEventTypeUserAction,
            attributes: nil
        )
        currentGameState = currentGameState!.addPeek()
    }
}

extension GameManager: GameplayInputControllerDelegate {
    func receivedInput(_ input: GameplayInput) {
        Analytics.sharedInstance().logEvent(
            withName: "gameplay_input",
            type: AnalyticsEventTypeUserAction,
            attributes: ["value": input.description]
        )
        switch input {
            case GameplayInput.back:
                currentGameState = nil
            case GameplayInput.forward:
                currentGameState = currentGameState!.advance()
            case .zero, .one, .two, .three, .four, .five, .six, .seven, .eight, .nine:
                if currentGameState?.currentChallengeIndex >= 0 && currentGameState?.currentChallengeIndex < currentGameState?.challenges.count {
                    currentGameState = currentGameState!.advance(input.rawValue)
                }
        }
    }
}

extension GameManager: LevelPickerViewControllerDelegate {
    func pickedLevel(_ levelId: String) {
        startGame(levelId)
    }
}

extension GameManager: SharingViewControllerDelegate {
    func repeatButtonPressed(_ sharingVC: SharingViewController) {
        if let levelId = currentGameState?.levelId {
            startGame(levelId)
        } else {
            fatalError("Repeat button pressed when there isn't a game that just finished!")
        }
    }
    
    func menuButtonPressed(_ sharingVC: SharingViewController) {
        currentGameState = nil
    }
}

protocol GameStateChangeListener: class {
    func gameStateChanged(_ change: GameStateChange)
    func gameStateChangeNotificationReceived(_ notification: Notification!)
}

extension NSObject {
    @objc func gameStateChangeNotificationReceived(_ notification: Notification!) {
        let change = notification!.userInfo![GameManager.GameStateChangeUserInfoKey]! as! GameStateChange
        if let gameChangeListener = self as? GameStateChangeListener {
            gameChangeListener.gameStateChanged(change)
        }
    }
}
