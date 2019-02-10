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
                NotificationCenter.default.post(
                    name: Notification.Name(rawValue: PlayerIdentityManager.playerIdentityChangeNotificationName),
                    object: self,
                    userInfo: [
                        PlayerIdentityManager.PlayerIdentityChangeNotificationOldValueKey: oldValue,
                        PlayerIdentityManager.PlayerIdentityChangeNotificationNewValueKey: currentIdentity
                    ])
            }
        }
    }
    private var gameCenterLoginViewController: UIViewController? = nil
    
    static let playerIdentityChangeNotificationName: String = "PLAYER_IDENTITY_CHANGED_NOTIFICATION"
    static let PlayerIdentityChangeNotificationOldValueKey: String = "OLD_VALUE"
    static let PlayerIdentityChangeNotificationNewValueKey: String = "NEW_VALUE"
    static let BestScoresChangeNotificationName: String = "BEST_SCORES_CHANGED"
    
    init() {
        currentIdentity = LocalPlayerIdentity()
        authenticateGameCenterPlayer()
    }
    
    func presentGameCenterLoginViewControllerIfAvailable() {
        if isGameCenterEnabled() {
            if let existingGameCenterLoginVC = gameCenterLoginViewController {
                UIApplication.shared.keyWindow!.rootViewController!.present(
                    existingGameCenterLoginVC,
                    animated: true,
                    completion: nil)
            }
        }
    }
    
    private func authenticateGameCenterPlayer() {
        let localGCPlayer = GKLocalPlayer.local
        localGCPlayer.authenticateHandler = { (loginVC: UIViewController?, error: Error?) -> (Void) in
            if let existingLoginVC = loginVC {
                self.gameCenterLoginViewController = existingLoginVC
                if self.currentIdentity is GameCenterPlayerIdentity {
                    self.currentIdentity = LocalPlayerIdentity()
                }
            } else if localGCPlayer.isAuthenticated {
                self.gameCenterLoginViewController = nil
                self.currentIdentity = GameCenterPlayerIdentity(gameCenterLocalPlayer: localGCPlayer)
            } else {
                self.gameCenterLoginViewController = nil
                if let gkError = error {
                    Analytics.sharedInstance().logEvent(
                        withName: "game_center_auth_error",
                        type: AnalyticsEventTypeWarning,
                        attributes: ["error": gkError.localizedDescription]
                    )
                }
                self.setGameCenterDisabled(true)
                self.currentIdentity = LocalPlayerIdentity()
            }
        }
    }
    
    let userDefaultsGameCenterDisabledKey = "game_center_disabled"
    private func setGameCenterDisabled(_ disabled: Bool) {
        UserDefaults.standard.set(disabled, forKey: userDefaultsGameCenterDisabledKey)
        UserDefaults.standard.synchronize()
    }
    
    private func isGameCenterEnabled() -> Bool { return !UserDefaults.standard.bool(forKey: userDefaultsGameCenterDisabledKey) }
    
    func subscribeToPlayerIdentityChangeNotifications(_ listener: PlayerIdentityChangeListener) {
        NotificationCenter.default.addObserver(
            listener,
            selector: #selector(NSObject.playerIdentityChangeNotificationReceived(_:)),
            name: NSNotification.Name(rawValue: PlayerIdentityManager.playerIdentityChangeNotificationName),
            object: self)
    }
    
    func unsubscribeFromPlayerIdentityChangeNotifications(_ listener: PlayerIdentityChangeListener) {
        NotificationCenter.default.removeObserver(
            listener,
            name: NSNotification.Name(rawValue: PlayerIdentityManager.playerIdentityChangeNotificationName),
            object: self)
    }
    
}

protocol PlayerIdentityChangeListener: class {
    func playerIdentityChanged(_ oldIdentity: PlayerIdentity, newIdentity: PlayerIdentity)
    func playerIdentityChangeNotificationReceived(_ notification: Notification!)
}

extension NSObject {
    @objc func playerIdentityChangeNotificationReceived(_ notification: Notification!) {
        let userInfo = notification!.userInfo!
        let oldPlayerIdentity = userInfo[PlayerIdentityManager.PlayerIdentityChangeNotificationOldValueKey]! as! PlayerIdentity
        let newPlayerIdentity = userInfo[PlayerIdentityManager.PlayerIdentityChangeNotificationNewValueKey]! as! PlayerIdentity
        if let playerIdentityChangeListener = self as? PlayerIdentityChangeListener {
            playerIdentityChangeListener.playerIdentityChanged(oldPlayerIdentity, newIdentity: newPlayerIdentity)
        }
    }
}
