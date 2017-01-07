//
//  ReviewElicitor.swift
//  recollect
//
//  Created by Vova Galchenko on 12/24/15.
//  Copyright © 2015 Vova Galchenko. All rights reserved.
//

import UIKit
import MessageUI

class ReviewElicitor: NSObject, GameStateChangeListener, MFMailComposeViewControllerDelegate {
    static let instance = ReviewElicitor()
    static private let NumFinishedGamesUserDefaultsKey = "num_finished_games"
    static private let FeedbackEmailAddress = "info@pryanik.com"
    static private let AppName = Bundle.main.infoDictionary!["CFBundleName"] as! String
    static private let NumGamesToFinishBeforeRating = 10
    
    private var numFinishedGamesSinceLastPrompt: Int =
        UserDefaults.standard.integer(forKey: ReviewElicitor.NumFinishedGamesUserDefaultsKey) {
            didSet {
                UserDefaults.standard
                    .set(numFinishedGamesSinceLastPrompt, forKey: ReviewElicitor.NumFinishedGamesUserDefaultsKey)
                UserDefaults.standard.synchronize()
            }
        }
    private var userOptedOut: Bool {
        get {
            return numFinishedGamesSinceLastPrompt < 0
        }
    }
    
    private override init() {
        super.init()
        GameManager.sharedInstance.subscribeToGameStateChangeNotifications(self)
    }
    
    deinit {
        GameManager.sharedInstance.unsubscribeFromGameStateChangeNotifications(self)
    }
    
    func gameStateChanged(_ change: GameStateChange) {
        if let finishedGame = change.newGameState,
            !userOptedOut &&
            finishedGame.isFinished() &&
            !(change.oldGameState?.isFinished() ?? true) {
            numFinishedGamesSinceLastPrompt += 1
            if numFinishedGamesSinceLastPrompt >= ReviewElicitor.NumGamesToFinishBeforeRating {
                self.numFinishedGamesSinceLastPrompt = 0
                showPrompt()
            }
        }
    }
    
    private func showPrompt() {
        let mailSupported = MFMailComposeViewController.canSendMail()
        let alertController = UIAlertController(
            title: "Do you like \(ReviewElicitor.AppName)?",
            message: "Please leave a review in the App Store\(mailSupported ? " or email us your feedback." : ".")",
            preferredStyle: .alert
        )
        alertController.addAction(
            UIAlertAction(title: "Leave a Review", style: .default) { _ -> Void in
                self.numFinishedGamesSinceLastPrompt = -1
                Analytics.sharedInstance().logEvent(
                    withName: "app_store_review",
                    type: AnalyticsEventTypeUserAction,
                    attributes: ["mail_supported": mailSupported ? "yes" : "no"]
                )
                let appStoreUrl = "itms-apps://itunes.apple.com/app/id961318875"
                UIApplication.shared.openURL(URL(string: appStoreUrl)!)
            }
        )
        if mailSupported {
            alertController.addAction(
                UIAlertAction(title: "Email Developer", style: .default) { _ -> Void in
                    let mailVC = MFMailComposeViewController()
                    mailVC.mailComposeDelegate = self
                    mailVC.setSubject("Feedback on \(ReviewElicitor.AppName)")
                    mailVC.setToRecipients([ReviewElicitor.FeedbackEmailAddress])
                    let controller = UIApplication.shared.keyWindow!.rootViewController!
                    controller.present(mailVC, animated: true, completion: nil)
                }
            )
        }
        alertController.addAction(
            UIAlertAction(title: "Dismiss", style: .cancel) { _ -> Void in
                Analytics.sharedInstance().logEvent(
                    withName: "review_elicitor_cancelled",
                    type: AnalyticsEventTypeUserAction,
                    attributes: ["mail_supported": mailSupported ? "yes" : "no"]
                )
                self.numFinishedGamesSinceLastPrompt = 0
            }
        )
        alertController.addAction(
            UIAlertAction(title: "Don't Ask Again", style: .destructive) { _ -> Void in
                Analytics.sharedInstance().logEvent(
                    withName: "review_elicitor_dont_ask_again",
                    type: AnalyticsEventTypeUserAction,
                    attributes: ["mail_supported": mailSupported ? "yes" : "no"]
                )
                self.numFinishedGamesSinceLastPrompt = -1
            }
        )
        UIApplication.shared.keyWindow!.rootViewController!
            .present(alertController, animated: true, completion: nil)
        Analytics.sharedInstance().logEvent(
            withName: "review_elicitor_prompt_shown",
            type: AnalyticsEventTypeViewChange,
            attributes: ["mail_supported": mailSupported ? "yes" : "no"]
        )
    }
    
    func mailComposeController(
        _ controller: MFMailComposeViewController,
        didFinishWith result: MFMailComposeResult,
        error: Error?
    ) {
        controller.dismiss(animated: true, completion: nil)
        switch (result) {
        case MFMailComposeResult.sent:
            Analytics.sharedInstance().logEvent(
                withName: "feedback_sent",
                type: AnalyticsEventTypeUserAction,
                attributes: nil
            )
            self.numFinishedGamesSinceLastPrompt = -1
        default:
            Analytics.sharedInstance().logEvent(
                withName: "feedback_sending_didnt_succeed",
                type: AnalyticsEventTypeUserAction,
                attributes: ["mail_sending_result": NSNumber(value: result.rawValue)]
            )
            showPrompt()
        }
    }
}
