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
    static private let AppName = NSBundle.mainBundle().infoDictionary!["CFBundleName"] as! String
    static private let NumGamesToFinishBeforeRating = 10
    
    private var numFinishedGamesSinceLastPrompt: Int =
        NSUserDefaults.standardUserDefaults().integerForKey(ReviewElicitor.NumFinishedGamesUserDefaultsKey) {
            didSet {
                NSUserDefaults.standardUserDefaults()
                    .setInteger(numFinishedGamesSinceLastPrompt, forKey: ReviewElicitor.NumFinishedGamesUserDefaultsKey)
                NSUserDefaults.standardUserDefaults().synchronize()
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
    
    func gameStateChanged(change: GameStateChange) {
        if let finishedGame = change.newGameState where
            !userOptedOut &&
            finishedGame.isFinished() &&
            !(change.oldGameState?.isFinished() ?? true) {
            numFinishedGamesSinceLastPrompt++
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
            preferredStyle: .Alert
        )
        alertController.addAction(
            UIAlertAction(title: "Leave a Review", style: .Default) { _ -> Void in
                self.numFinishedGamesSinceLastPrompt = -1
                Analytics.sharedInstance().logEventWithName(
                    "app_store_review",
                    type: AnalyticsEventTypeUserAction,
                    attributes: ["mail_supported": mailSupported ? "yes" : "no"]
                )
                let appStoreUrl = "itms-apps://itunes.apple.com/app/id961318875"
                UIApplication.sharedApplication().openURL(NSURL(string: appStoreUrl)!)
            }
        )
        if mailSupported {
            alertController.addAction(
                UIAlertAction(title: "Email Developer", style: .Default) { _ -> Void in
                    let mailVC = MFMailComposeViewController()
                    mailVC.mailComposeDelegate = self
                    mailVC.setSubject("Feedback on \(ReviewElicitor.AppName)")
                    mailVC.setToRecipients([ReviewElicitor.FeedbackEmailAddress])
                    let controller = UIApplication.sharedApplication().keyWindow!.rootViewController!
                    controller.presentViewController(mailVC, animated: true, completion: nil)
                }
            )
        }
        alertController.addAction(
            UIAlertAction(title: "Dismiss", style: .Cancel) { _ -> Void in
                Analytics.sharedInstance().logEventWithName(
                    "review_elicitor_cancelled",
                    type: AnalyticsEventTypeUserAction,
                    attributes: ["mail_supported": mailSupported ? "yes" : "no"]
                )
                self.numFinishedGamesSinceLastPrompt = 0
            }
        )
        alertController.addAction(
            UIAlertAction(title: "Don't Ask Again", style: .Destructive) { _ -> Void in
                Analytics.sharedInstance().logEventWithName(
                    "review_elicitor_dont_ask_again",
                    type: AnalyticsEventTypeUserAction,
                    attributes: ["mail_supported": mailSupported ? "yes" : "no"]
                )
                self.numFinishedGamesSinceLastPrompt = -1
            }
        )
        UIApplication.sharedApplication().keyWindow!.rootViewController!
            .presentViewController(alertController, animated: true, completion: nil)
        Analytics.sharedInstance().logEventWithName(
            "review_elicitor_prompt_shown",
            type: AnalyticsEventTypeViewChange,
            attributes: ["mail_supported": mailSupported ? "yes" : "no"]
        )
    }
    
    func mailComposeController(
        controller: MFMailComposeViewController,
        didFinishWithResult result: MFMailComposeResult,
        error: NSError?
    ) {
        controller.dismissViewControllerAnimated(true, completion: nil)
        switch (result) {
        case MFMailComposeResultSent:
            Analytics.sharedInstance().logEventWithName(
                "feedback_sent",
                type: AnalyticsEventTypeUserAction,
                attributes: nil
            )
            self.numFinishedGamesSinceLastPrompt = -1
        default:
            Analytics.sharedInstance().logEventWithName(
                "feedback_sending_didnt_succeed",
                type: AnalyticsEventTypeUserAction,
                attributes: ["mail_sending_result": NSNumber(unsignedInt: result.rawValue)]
            )
            showPrompt()
        }
    }
}
