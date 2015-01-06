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
        return ["1", "2", "3", "4"]
    }
    
    class var GameStateChangeNotificationName: String {
        return "GAME_STATE_CHANGED"
    }
    
    class var GameStateChangeUserInfoKey: NSString {
        return "change"
    }
    
    var currentGameState: GameState? {
        didSet {
            NSNotificationCenter.defaultCenter().postNotificationName(
                GameManager.GameStateChangeNotificationName,
                object: self,
                userInfo: [GameManager.GameStateChangeUserInfoKey: GameStateChange(oldGameState: oldValue, newGameState: currentGameState)])
        }
    }
    
    func startGame(gameLevelId: String) {
        assert(self.currentGameState == nil, "Can't start a game when one is already in progress!")
        self.currentGameState = GameState(n: gameLevelId.toInt()!, numRounds: 5)
    }
    
    func subscribeToGameStateChangeNotifications(listener: GameStateChangeListener) {
        NSNotificationCenter.defaultCenter().addObserver(
            listener,
            selector: "gameStateChangeNotificationReceived:",
            name: GameManager.GameStateChangeNotificationName,
            object: GameManager.sharedInstance)
    }
    
    func unsubscribeFromGameStateChangeNotifications(listener: GameStateChangeListener) {
        NSNotificationCenter.defaultCenter().removeObserver(listener, name: GameManager.GameStateChangeNotificationName, object: GameManager.sharedInstance)
    }
}

extension GameManager: GameplayInputControllerDelegate {
    func receivedInput(input: GameplayInput) {
        switch input {
            case GameplayInput.Back:
                currentGameState = nil
            case GameplayInput.Forward:
                currentGameState = currentGameState!.advance()
            case .Zero, .One, .Two, .Three, .Four, .Five, .Six, .Seven, .Eight, .Nine:
                currentGameState = currentGameState!.advance(userInput: input.rawValue)
            default:
                fatalError("Can't understand user input <\(input)>.")
        }
    }
}

extension GameManager: LevelPickerViewControllerDelegate {
    func pickedLevel(levelId: String) {
        GameManager.sharedInstance.startGame(levelId)
    }
}

@objc protocol GameStateChangeListener {
    func gameStateChanged(change: GameStateChange)
    func gameStateChangeNotificationReceived(notification: NSNotification!)
}

extension UIViewController {
    func gameStateChangeNotificationReceived(notification: NSNotification!) {
        let change = notification!.userInfo![GameManager.GameStateChangeUserInfoKey]! as GameStateChange
        if let gameChangeListener = self as? GameStateChangeListener {
            gameChangeListener.gameStateChanged(change)
        }
    }
}