//
//  LevelPickerViewController.swift
//  recollect
//
//  Created by Vova Galchenko on 12/27/14.
//  Copyright (c) 2014 Vova Galchenko. All rights reserved.
//

import UIKit

class LevelPickerViewController: HalfScreenViewController, UIGestureRecognizerDelegate, PlayerIdentityChangeListener {
    
    let horizontalPadding: CGFloat = 50
    let verticalPadding: CGFloat = 20
    var scrollView: UIScrollView!
    
    var bestTimeValueLabel: ManglableLabel?
    var bestTimeKeyLabel: ManglableLabel?
    var bestTimeLabelFadeTimer: NSTimer?
    
    let delegate: LevelPickerViewControllerDelegate
    
    init(delegate: LevelPickerViewControllerDelegate) {
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
        
        PlayerIdentityManager.sharedInstance.subscribeToPlayerIdentityChangeNotifications(self)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) won't be implemented because I ain't using xibs")
    }
    
    deinit {
        scrollView?.delegate = nil
        PlayerIdentityManager.sharedInstance.unsubscribeFromPlayerIdentityChangeNotifications(self)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let swipeLabel = informationLabel()
        swipeLabel.text = "SWIPE TO CHOOSE A LEVEL."
        view.addSubview(swipeLabel)
        
        let tapLabel = informationLabel()
        tapLabel.text = "TAP TO START."
        view.addSubview(tapLabel)
        
        scrollView = UIScrollView()
        scrollView.delegate = self
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.alwaysBounceHorizontal = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        view.addSubview(scrollView)
        view.bringSubviewToFront(scrollView)
        let scrollViewConstraints =
            NSLayoutConstraint.constraintsWithVisualFormat(
                "H:|[scrollView]|",
                options: NSLayoutFormatOptions(rawValue: 0),
                metrics: nil,
                views: ["scrollView": scrollView]) +
            NSLayoutConstraint.constraintsWithVisualFormat(
                "V:|[scrollView]|",
                options: NSLayoutFormatOptions(rawValue: 0),
                metrics: nil,
                views: ["scrollView": scrollView])
        
        let (levelLabels, horizontalConstraint) =
            GameManager.gameLevels.reduce(([(String, ManglableLabel)](), "H:|-(>=\(horizontalPadding))-")) { (acc: ([(String, ManglableLabel)], String), nextLevelName: String) in
                let label = self.levelLabel(nextLevelName)
                let labelName = "label_\(label.hash)"
                var labelsArray = acc.0
                labelsArray.append((labelName, label))
                return (labelsArray, acc.1 + "[\(labelName)]-(>=\(self.horizontalPadding))-")
            }
        
        var levelLabelConstraints = [NSLayoutConstraint]()
        var labelsDict = [String: ManglableLabel]()
        for (index, (labelName, label)) in levelLabels.enumerate() {
            scrollView.addSubview(label)
            levelLabelConstraints += [
                NSLayoutConstraint(
                    item: label,
                    attribute: NSLayoutAttribute.Top,
                    relatedBy: NSLayoutRelation.Equal,
                    toItem: view,
                    attribute: NSLayoutAttribute.Top,
                    multiplier: 1.0,
                    constant: 0.0),
                NSLayoutConstraint(
                    item: label,
                    attribute: NSLayoutAttribute.Bottom,
                    relatedBy: NSLayoutRelation.Equal,
                    toItem: view,
                    attribute: NSLayoutAttribute.Bottom,
                    multiplier: 1.0,
                    constant: 0.0)
            ]
            if index == 0 {
                levelLabelConstraints.append(
                    NSLayoutConstraint(
                        item: label,
                        attribute: NSLayoutAttribute.Left,
                        relatedBy: NSLayoutRelation.Equal,
                        toItem: scrollView,
                        attribute: NSLayoutAttribute.Left,
                        multiplier: 1.0,
                        constant: view.bounds.size.width/2 - label.intrinsicContentSize().width/2)
                )
            } else if index == levelLabels.count - 1 {
                levelLabelConstraints.append(
                    NSLayoutConstraint(
                        item: label,
                        attribute: NSLayoutAttribute.Right,
                        relatedBy: NSLayoutRelation.Equal,
                        toItem: scrollView,
                        attribute: NSLayoutAttribute.Right,
                        multiplier: 1.0,
                        constant: label.intrinsicContentSize().width/2 - view.bounds.size.width/2)
                )
            }
            labelsDict[labelName] = label
        }
        
        levelLabelConstraints += NSLayoutConstraint.constraintsWithVisualFormat(
            horizontalConstraint + "|",
            options: NSLayoutFormatOptions(rawValue: 0),
            metrics: nil,
            views: labelsDict)
        
        let allConstraints =
            NSLayoutConstraint.constraintsWithVisualFormat(
                "V:|-(\(verticalPadding))-[swipeLabel][tapLabel]",
                options: NSLayoutFormatOptions(rawValue: 0),
                metrics: nil,
                views: ["swipeLabel": swipeLabel, "tapLabel": tapLabel]) +
            scrollViewConstraints +
            [
                NSLayoutConstraint(
                    item: swipeLabel,
                    attribute: NSLayoutAttribute.CenterX,
                    relatedBy: NSLayoutRelation.Equal,
                    toItem: view,
                    attribute: NSLayoutAttribute.CenterX,
                    multiplier: 1.0,
                    constant: 0.0),
                NSLayoutConstraint(
                    item: tapLabel,
                    attribute: NSLayoutAttribute.CenterX,
                    relatedBy: NSLayoutRelation.Equal,
                    toItem: view,
                    attribute: NSLayoutAttribute.CenterX,
                    multiplier: 1.0,
                    constant: 0.0),
            ] + levelLabelConstraints
        view.addConstraints(allConstraints)
        
        bestTimeKeyLabel = informationLabel()
        bestTimeKeyLabel!.text = "BEST TIME"
        bestTimeKeyLabel!.alpha = 0.0
        view.addSubview(bestTimeKeyLabel!)
        
        bestTimeValueLabel = informationLabel()
        bestTimeValueLabel!.textColor = DesignLanguage.AccentTextColor
        bestTimeValueLabel!.alpha = 0.0
        view.addSubview(bestTimeValueLabel!)
        
        view.addConstraints(
            NSLayoutConstraint.constraintsWithVisualFormat(
                "V:[bestTimeValue][bestTimeKey]-(\(verticalPadding))-|",
                options: NSLayoutFormatOptions(rawValue: 0),
                metrics: nil,
                views: ["bestTimeValue" : bestTimeValueLabel!, "bestTimeKey" : bestTimeKeyLabel!]) +
            [
                NSLayoutConstraint(
                    item: bestTimeValueLabel!,
                    attribute: NSLayoutAttribute.CenterX,
                    relatedBy: NSLayoutRelation.Equal,
                    toItem: view,
                    attribute: NSLayoutAttribute.CenterX,
                    multiplier: 1.0,
                    constant: 0.0),
                NSLayoutConstraint(
                    item: bestTimeKeyLabel!,
                    attribute: NSLayoutAttribute.CenterX,
                    relatedBy: NSLayoutRelation.Equal,
                    toItem: view,
                    attribute: NSLayoutAttribute.CenterX,
                    multiplier: 1.0,
                    constant: 0.0),
            ]
        )
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: "handleTap:")
        tapRecognizer.numberOfTapsRequired = 1
        tapRecognizer.enabled = true
        tapRecognizer.cancelsTouchesInView = true
        tapRecognizer.delegate = self
        scrollView.addGestureRecognizer(tapRecognizer)
        
        view.setNeedsLayout()
        view.layoutIfNeeded()
        
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: "bestScoreChanged:",
            name: PlayerIdentityManager.BestScoresChangeNotificationName,
            object: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        scrollViewDidScroll(scrollView)
        fadeInTimeLabels()
    }
    
    func playerIdentityChanged(oldIdentity: PlayerIdentity, newIdentity: PlayerIdentity) {
        assert(NSThread.isMainThread(), "We are relying on player identity changes happening on the main thread.")
        if !scrollView.dragging {
            fadeInTimeLabels()
        }
    }
    
    func bestScoreChanged(notification: NSNotification) {
        if !scrollView.dragging {
            fadeInTimeLabels()
        }
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func handleTap(tapRecognizer: UITapGestureRecognizer) {
        let scrollView = tapRecognizer.view! as! UIScrollView
        var minDistance = CGFloat.max
        var labelClosestToCenter: ManglableLabel?
        for label in scrollView.subviews {
            let labelCenter = CGPointMake(label.center.x - scrollView.contentOffset.x, label.center.y)
            let xDistance = labelCenter.x - scrollView.center.x
            if (abs(xDistance) < abs(minDistance) && label is ManglableLabel) {
                minDistance = xDistance
                labelClosestToCenter = (label as! ManglableLabel)
            }
        }
        
        delegate.pickedLevel(labelClosestToCenter!.text!)
    }
    
    private func informationLabel() -> ManglableLabel {
        let instructionsLabel = ManglableLabel()
        instructionsLabel.font = UIFont(name: "AvenirNextCondensed-DemiBold", size: 18)
        instructionsLabel.textColor = DesignLanguage.NeverActiveTextColor
        instructionsLabel.textAlignment = NSTextAlignment.Center
        instructionsLabel.numberOfLines = 1
        return instructionsLabel
    }
    
    private func levelLabel(levelName: String) -> ManglableLabel {
        let levelLabel = ManglableLabel()
        levelLabel.font = UIFont(name: "AvenirNext-UltraLight", size: 100.75)
        levelLabel.textColor = DesignLanguage.InactiveTextColor
        levelLabel.numberOfLines = 1
        levelLabel.setContentCompressionResistancePriority(1000, forAxis: UILayoutConstraintAxis.Horizontal)
        levelLabel.setContentCompressionResistancePriority(1000, forAxis: UILayoutConstraintAxis.Vertical)
        levelLabel.setContentHuggingPriority(250, forAxis: UILayoutConstraintAxis.Horizontal)
        levelLabel.text = levelName
        return levelLabel
    }
}

extension LevelPickerViewController: UIScrollViewDelegate {
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if (!decelerate) {
            snapToNearestLevelLabel(scrollView)
        }
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        snapToNearestLevelLabel(scrollView)
    }
    
    private func fadeInTimeLabels() {
        refreshBestTimeLabels()
        let haveBestScore = (self.bestTimeValueLabel?.text ?? "").characters.count > 0
        UIView.animateWithDuration(
            DesignLanguage.MinorAnimationDuration,
            delay: 0.0,
            options: UIViewAnimationOptions.BeginFromCurrentState,
            animations: { () -> Void in
                self.bestTimeKeyLabel?.alpha = haveBestScore ? 1.0 : 0.0
                self.bestTimeValueLabel?.alpha = haveBestScore ? 1.0 : 0.0
            }, completion: nil)
    }
    
    private func refreshLevelLabelColors() {
        var inactiveR:CGFloat = 0, inactiveG:CGFloat = 0, inactiveB:CGFloat = 0, activeR:CGFloat = 0, activeG:CGFloat = 0, activeB:CGFloat = 0
        DesignLanguage.InactiveTextColor.getRed(&inactiveR, green: &inactiveG, blue: &inactiveB, alpha: nil)
        DesignLanguage.ActiveTextColor.getRed(&activeR, green: &activeG, blue: &activeB, alpha: nil)
        func interpolate(distance: CGFloat, from: CGFloat, to: CGFloat) -> CGFloat {
            var clampingFunc: (CGFloat) -> CGFloat = { max($0, 0) }
            if (from > to) {
                clampingFunc = { min($0, 0) }
            }
            let r = from + clampingFunc(((horizontalPadding - distance)/horizontalPadding) * abs(from - to))
            return r
        }
        for subview in scrollView.subviews {
            if let label = subview as? ManglableLabel {
                let labelCenter = CGPointMake(label.center.x - scrollView.contentOffset.x, label.center.y)
                let xDistance = abs(labelCenter.x - scrollView.center.x)
                label.textColor = UIColor(
                    red: interpolate(xDistance, from: inactiveR, to: activeR),
                    green: interpolate(xDistance, from: inactiveG, to: activeG),
                    blue: interpolate(xDistance, from: inactiveB, to: activeB),
                    alpha: 1.0)
            }
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        refreshLevelLabelColors()
        if scrollView.dragging && (bestTimeValueLabel?.alpha > 0 || bestTimeKeyLabel?.alpha > 0) {
            UIView.animateWithDuration(
                DesignLanguage.MinorAnimationDuration,
                delay: 0.0,
                options: UIViewAnimationOptions.BeginFromCurrentState,
                animations: { () -> Void in
                    self.bestTimeKeyLabel?.alpha = 0
                    self.bestTimeValueLabel?.alpha = 0
                },
                completion: nil
            )
        }
    }
    
    func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
        scrollView.userInteractionEnabled = true
    }
    
    private func refreshBestTimeLabels() {
        PlayerIdentityManager.sharedInstance.currentIdentity.getMyBestScores() { bestScores in
            // TODO: All of this looking for the closest label shit can be improved
            // by using the scrollview offset to figure out the closest label.
            var minDistanceToLabel = CGFloat.max
            var levelId = ""
            for subview in self.scrollView.subviews {
                if let manglableLabel = subview as? ManglableLabel {
                    let labelCenter = CGPointMake(manglableLabel.center.x - self.scrollView.contentOffset.x, manglableLabel.center.y)
                    let xDistance = abs(labelCenter.x - self.scrollView.center.x)
                    if (xDistance < minDistanceToLabel) {
                        minDistanceToLabel = xDistance
                        levelId = manglableLabel.originalText ?? manglableLabel.text!
                    }
                }
            }
            if let bestTime = bestScores[levelId] {
                self.bestTimeValueLabel?.text = bestTime.time.minuteSecondCentisecondString()
            } else {
                self.bestTimeValueLabel?.text = ""
            }
        }
    }
    
    private func snapToNearestLevelLabel(scrollView: UIScrollView) {
        // TODO: All of this looking for the closest label shit can be improved
        // by using the scrollview offset to figure out the closest label.
        var minDistance = CGFloat.max
        for label in scrollView.subviews {
            let labelCenter = CGPointMake(label.center.x - scrollView.contentOffset.x, label.center.y)
            let xDistance = labelCenter.x - scrollView.center.x
            if (abs(xDistance) < abs(minDistance)) {
                minDistance = xDistance
            }
        }
        scrollView.userInteractionEnabled = false
        scrollView.setContentOffset(CGPointMake(scrollView.contentOffset.x + minDistance, scrollView.contentOffset.y), animated: true)
        
        fadeInTimeLabels()
    }
}

protocol LevelPickerViewControllerDelegate {
    func pickedLevel(levelId: String)
}
