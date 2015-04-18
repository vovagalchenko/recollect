//
//  PlayerIdentityManager.swift
//  recollect
//
//  Created by Vova Galchenko on 1/5/15.
//  Copyright (c) 2015 Vova Galchenko. All rights reserved.
//

import Foundation
import GameKit

class PlayerIdentityManager {
    
    class var sharedInstance : PlayerIdentityManager {
        struct Static {
            static let instance : PlayerIdentityManager = PlayerIdentityManager()
        }
        return Static.instance
    }
    
    var currentIdentity: PlayerIdentity {
        didSet {
            if oldValue.playerId != currentIdentity.playerId {
                NSNotificationCenter.defaultCenter().postNotificationName(
                    PlayerIdentityManager.playerIdentityChangeNotificationName,
                    object: self,
                    userInfo: [
                        PlayerIdentityManager.playerIdentityChangeNotificationOldValueKey: oldValue,
                        PlayerIdentityManager.playerIdentityChangeNotificationNewValueKey: currentIdentity
                    ])
            }
        }
    }
    private var gameCenterLoginViewController: UIViewController? = nil
    
    class var playerIdentityChangeNotificationName: String {
        return "PLAYER_IDENTITY_CHANGED_NOTIFICATION"
    }
    class var playerIdentityChangeNotificationOldValueKey: String {
        return "OLD_VALUE"
    }
    class var playerIdentityChangeNotificationNewValueKey: String {
        return "NEW_VALUE"
    }
    
    init() {
        currentIdentity = PlayerIdentity()
        authenticateGameCenterPlayer()
    }
    
    func presentGameCenterLoginViewControllerIfAvailable() {
        if isGameCenterEnabled() {
            if let existingGameCenterLoginVC = gameCenterLoginViewController {
                UIApplication.sharedApplication().keyWindow!.rootViewController!.presentViewController(
                    existingGameCenterLoginVC,
                    animated: true,
                    completion: nil)
            }
        }
    }
    
    private func authenticateGameCenterPlayer() {
        let localGCPlayer = GKLocalPlayer.localPlayer()
        localGCPlayer.authenticateHandler = { (loginVC: UIViewController?, error: NSError?) -> (Void) in
            if let existingLoginVC = loginVC {
                self.gameCenterLoginViewController = existingLoginVC
                if self.currentIdentity is GameCenterPlayerIdentity {
                    self.currentIdentity = PlayerIdentity()
                }
            } else if localGCPlayer.authenticated {
                self.gameCenterLoginViewController = nil
                self.currentIdentity = GameCenterPlayerIdentity(gameCenterLocalPlayer: localGCPlayer)
            } else {
                self.gameCenterLoginViewController = nil
                if let gkError = error {
                    NSLog("RECEIVED GAME CENTER ERROR: \(gkError)")
                }
                self.setGameCenterDisabled(true)
                self.currentIdentity = PlayerIdentity()
            }
        }
    }
    
    let userDefaultsGameCenterDisabledKey = "game_center_disabled"
    private func setGameCenterDisabled(disabled: Bool) {
        NSUserDefaults.standardUserDefaults().setBool(disabled, forKey: userDefaultsGameCenterDisabledKey)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    private func isGameCenterEnabled() -> Bool { return !NSUserDefaults.standardUserDefaults().boolForKey(userDefaultsGameCenterDisabledKey) }
    
    func subscribeToPlayerIdentityChangeNotifications(listener: PlayerIdentityChangeListener) {
        NSNotificationCenter.defaultCenter().addObserver(
            listener,
            selector: "playerIdentityChangeNotificationReceived:",
            name: PlayerIdentityManager.playerIdentityChangeNotificationName,
            object: self)
    }
    
    func unsubscribeFromPlayerIdentityChangeNotifications(listener: PlayerIdentityChangeListener) {
        NSNotificationCenter.defaultCenter().removeObserver(
            listener,
            name: PlayerIdentityManager.playerIdentityChangeNotificationName,
            object: self)
    }
    
}

@objc protocol PlayerIdentityChangeListener {
    func playerIdentityChanged(oldIdentity: PlayerIdentity, newIdentity: PlayerIdentity)
    @objc func playerIdentityChangeNotificationReceived(notification: NSNotification!)
}

extension NSObject {
    @objc func playerIdentityChangeNotificationReceived(notification: NSNotification!) {
        let userInfo = notification!.userInfo!
        let oldPlayerIdentity = userInfo[PlayerIdentityManager.playerIdentityChangeNotificationOldValueKey]! as! PlayerIdentity
        let newPlayerIdentity = userInfo[PlayerIdentityManager.playerIdentityChangeNotificationNewValueKey]! as! PlayerIdentity
        if let playerIdentityChangeListener = self as? PlayerIdentityChangeListener {
            playerIdentityChangeListener.playerIdentityChanged(oldPlayerIdentity, newIdentity: newPlayerIdentity)
        }
    }
}