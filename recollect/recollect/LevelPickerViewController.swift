//
//  LevelPickerViewController.swift
//  recollect
//
//  Created by Vova Galchenko on 12/27/14.
//  Copyright (c) 2014 Vova Galchenko. All rights reserved.
//

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
private func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class LevelPickerViewController: HalfScreenViewController, UIGestureRecognizerDelegate, PlayerIdentityChangeListener {
    
    let horizontalPadding: CGFloat = 50
    let verticalPadding: CGFloat = 20
    var scrollView: UIScrollView!
    
    var bestTimeValueLabel: ManglableLabel?
    var bestTimeKeyLabel: ManglableLabel?
    var bestTimeLabelFadeTimer: Timer?
    
    let delegate: LevelPickerViewControllerDelegate
    
    init(delegate: LevelPickerViewControllerDelegate) {
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
        
        PlayerIdentityManager.sharedInstance.subscribeToPlayerIdentityChangeNotifications(self)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(LevelPickerViewController.appDidBecomeActive(_:)),
            name: NSNotification.Name.UIApplicationDidBecomeActive,
            object: nil
        )
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) won't be implemented because I ain't using xibs")
    }
    
    deinit {
        scrollView?.delegate = nil
        PlayerIdentityManager.sharedInstance.unsubscribeFromPlayerIdentityChangeNotifications(self)
        NotificationCenter.default.removeObserver(self)
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
        view.bringSubview(toFront: scrollView)
        let scrollViewConstraints =
            NSLayoutConstraint.constraints(
                withVisualFormat: "H:|[scrollView]|",
                options: NSLayoutFormatOptions(rawValue: 0),
                metrics: nil,
                views: ["scrollView": scrollView]) +
            NSLayoutConstraint.constraints(
                withVisualFormat: "V:|[scrollView]|",
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
        for (index, (labelName, label)) in levelLabels.enumerated() {
            scrollView.addSubview(label)
            levelLabelConstraints += [
                NSLayoutConstraint(
                    item: label,
                    attribute: NSLayoutAttribute.top,
                    relatedBy: NSLayoutRelation.equal,
                    toItem: view,
                    attribute: NSLayoutAttribute.top,
                    multiplier: 1.0,
                    constant: 0.0),
                NSLayoutConstraint(
                    item: label,
                    attribute: NSLayoutAttribute.bottom,
                    relatedBy: NSLayoutRelation.equal,
                    toItem: view,
                    attribute: NSLayoutAttribute.bottom,
                    multiplier: 1.0,
                    constant: 0.0)
            ]
            if index == 0 {
                levelLabelConstraints.append(
                    NSLayoutConstraint(
                        item: label,
                        attribute: NSLayoutAttribute.left,
                        relatedBy: NSLayoutRelation.equal,
                        toItem: scrollView,
                        attribute: NSLayoutAttribute.left,
                        multiplier: 1.0,
                        constant: view.bounds.size.width/2 - label.intrinsicContentSize.width/2)
                )
            } else if index == levelLabels.count - 1 {
                levelLabelConstraints.append(
                    NSLayoutConstraint(
                        item: label,
                        attribute: NSLayoutAttribute.right,
                        relatedBy: NSLayoutRelation.equal,
                        toItem: scrollView,
                        attribute: NSLayoutAttribute.right,
                        multiplier: 1.0,
                        constant: label.intrinsicContentSize.width/2 - view.bounds.size.width/2)
                )
            }
            labelsDict[labelName] = label
        }
        
        levelLabelConstraints += NSLayoutConstraint.constraints(
            withVisualFormat: horizontalConstraint + "|",
            options: NSLayoutFormatOptions(rawValue: 0),
            metrics: nil,
            views: labelsDict)
        
        let allConstraints =
            NSLayoutConstraint.constraints(
                withVisualFormat: "V:|-(\(verticalPadding))-[swipeLabel][tapLabel]",
                options: NSLayoutFormatOptions(rawValue: 0),
                metrics: nil,
                views: ["swipeLabel": swipeLabel, "tapLabel": tapLabel]) +
            scrollViewConstraints +
            [
                NSLayoutConstraint(
                    item: swipeLabel,
                    attribute: NSLayoutAttribute.centerX,
                    relatedBy: NSLayoutRelation.equal,
                    toItem: view,
                    attribute: NSLayoutAttribute.centerX,
                    multiplier: 1.0,
                    constant: 0.0),
                NSLayoutConstraint(
                    item: tapLabel,
                    attribute: NSLayoutAttribute.centerX,
                    relatedBy: NSLayoutRelation.equal,
                    toItem: view,
                    attribute: NSLayoutAttribute.centerX,
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
            NSLayoutConstraint.constraints(
                withVisualFormat: "V:[bestTimeValue][bestTimeKey]-(\(verticalPadding))-|",
                options: NSLayoutFormatOptions(rawValue: 0),
                metrics: nil,
                views: ["bestTimeValue" : bestTimeValueLabel!, "bestTimeKey" : bestTimeKeyLabel!]) +
            [
                NSLayoutConstraint(
                    item: bestTimeValueLabel!,
                    attribute: NSLayoutAttribute.centerX,
                    relatedBy: NSLayoutRelation.equal,
                    toItem: view,
                    attribute: NSLayoutAttribute.centerX,
                    multiplier: 1.0,
                    constant: 0.0),
                NSLayoutConstraint(
                    item: bestTimeKeyLabel!,
                    attribute: NSLayoutAttribute.centerX,
                    relatedBy: NSLayoutRelation.equal,
                    toItem: view,
                    attribute: NSLayoutAttribute.centerX,
                    multiplier: 1.0,
                    constant: 0.0),
            ]
        )
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(LevelPickerViewController.handleTap(_:)))
        tapRecognizer.numberOfTapsRequired = 1
        tapRecognizer.isEnabled = true
        tapRecognizer.cancelsTouchesInView = true
        tapRecognizer.delegate = self
        scrollView.addGestureRecognizer(tapRecognizer)
        
        view.setNeedsLayout()
        view.layoutIfNeeded()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(LevelPickerViewController.bestScoreChanged(_:)),
            name: NSNotification.Name(rawValue: PlayerIdentityManager.BestScoresChangeNotificationName),
            object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        initializeViewForAppearance()
    }
    
    @objc private func appDidBecomeActive(_ notification: Notification) {
        initializeViewForAppearance()
    }
    
    private func initializeViewForAppearance() {
        scrollViewDidScroll(scrollView)
        fadeInTimeLabels()
    }
    
    func playerIdentityChanged(_ oldIdentity: PlayerIdentity, newIdentity: PlayerIdentity) {
        assert(Thread.isMainThread, "We are relying on player identity changes happening on the main thread.")
        if !scrollView.isDragging {
            fadeInTimeLabels()
        }
    }
    
    func bestScoreChanged(_ notification: Notification) {
        if !scrollView.isDragging {
            fadeInTimeLabels()
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func handleTap(_ tapRecognizer: UITapGestureRecognizer) {
        let scrollView = tapRecognizer.view! as! UIScrollView
        var minDistance = CGFloat.greatestFiniteMagnitude
        var labelClosestToCenter: ManglableLabel?
        for label in scrollView.subviews {
            let labelCenter = CGPoint(x: label.center.x - scrollView.contentOffset.x, y: label.center.y)
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
        instructionsLabel.textAlignment = NSTextAlignment.center
        instructionsLabel.numberOfLines = 1
        return instructionsLabel
    }
    
    private func levelLabel(_ levelName: String) -> ManglableLabel {
        let levelLabel = ManglableLabel()
        levelLabel.font = UIFont(name: "AvenirNext-UltraLight", size: 100.75)
        levelLabel.textColor = DesignLanguage.InactiveTextColor
        levelLabel.numberOfLines = 1
        levelLabel.setContentCompressionResistancePriority(1000, for: UILayoutConstraintAxis.horizontal)
        levelLabel.setContentCompressionResistancePriority(1000, for: UILayoutConstraintAxis.vertical)
        levelLabel.setContentHuggingPriority(250, for: UILayoutConstraintAxis.horizontal)
        levelLabel.text = levelName
        return levelLabel
    }
}

extension LevelPickerViewController: UIScrollViewDelegate {
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if (!decelerate) {
            snapToNearestLevelLabel(scrollView)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        snapToNearestLevelLabel(scrollView)
    }
    
    fileprivate func fadeInTimeLabels() {
        refreshBestTimeLabels()
        let haveBestScore = (self.bestTimeValueLabel?.text ?? "").characters.count > 0
        UIView.animate(
            withDuration: DesignLanguage.MinorAnimationDuration,
            delay: 0.0,
            options: UIViewAnimationOptions.beginFromCurrentState,
            animations: { () -> Void in
                self.bestTimeKeyLabel?.alpha = haveBestScore ? 1.0 : 0.0
                self.bestTimeValueLabel?.alpha = haveBestScore ? 1.0 : 0.0
            }, completion: nil)
    }
    
    private func refreshLevelLabelColors() {
        var inactiveR:CGFloat = 0, inactiveG:CGFloat = 0, inactiveB:CGFloat = 0, activeR:CGFloat = 0, activeG:CGFloat = 0, activeB:CGFloat = 0
        DesignLanguage.InactiveTextColor.getRed(&inactiveR, green: &inactiveG, blue: &inactiveB, alpha: nil)
        DesignLanguage.ActiveTextColor.getRed(&activeR, green: &activeG, blue: &activeB, alpha: nil)
        func interpolate(_ distance: CGFloat, from: CGFloat, to: CGFloat) -> CGFloat {
            var clampingFunc: (CGFloat) -> CGFloat = { max($0, 0) }
            if (from > to) {
                clampingFunc = { min($0, 0) }
            }
            let r = from + clampingFunc(((horizontalPadding - distance)/horizontalPadding) * abs(from - to))
            return r
        }
        for subview in scrollView.subviews {
            if let label = subview as? ManglableLabel {
                let labelCenter = CGPoint(x: label.center.x - scrollView.contentOffset.x, y: label.center.y)
                let xDistance = abs(labelCenter.x - scrollView.center.x)
                label.textColor = UIColor(
                    red: interpolate(xDistance, from: inactiveR, to: activeR),
                    green: interpolate(xDistance, from: inactiveG, to: activeG),
                    blue: interpolate(xDistance, from: inactiveB, to: activeB),
                    alpha: 1.0)
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        refreshLevelLabelColors()
        if scrollView.isDragging && (bestTimeValueLabel?.alpha > 0 || bestTimeKeyLabel?.alpha > 0) {
            UIView.animate(
                withDuration: DesignLanguage.MinorAnimationDuration,
                delay: 0.0,
                options: UIViewAnimationOptions.beginFromCurrentState,
                animations: { () -> Void in
                    self.bestTimeKeyLabel?.alpha = 0
                    self.bestTimeValueLabel?.alpha = 0
                },
                completion: nil
            )
        }
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        scrollView.isUserInteractionEnabled = true
    }
    
    private func refreshBestTimeLabels() {
        PlayerIdentityManager.sharedInstance.currentIdentity.getMyBestScores() { bestScores in
            // TODO: All of this looking for the closest label shit can be improved
            // by using the scrollview offset to figure out the closest label.
            var minDistanceToLabel = CGFloat.greatestFiniteMagnitude
            var levelId = ""
            for subview in self.scrollView.subviews {
                if let manglableLabel = subview as? ManglableLabel {
                    let labelCenter = CGPoint(x: manglableLabel.center.x - self.scrollView.contentOffset.x, y: manglableLabel.center.y)
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
    
    private func snapToNearestLevelLabel(_ scrollView: UIScrollView) {
        // TODO: All of this looking for the closest label shit can be improved
        // by using the scrollview offset to figure out the closest label.
        var minDistance = CGFloat.greatestFiniteMagnitude
        for label in scrollView.subviews {
            let labelCenter = CGPoint(x: label.center.x - scrollView.contentOffset.x, y: label.center.y)
            let xDistance = labelCenter.x - scrollView.center.x
            if (abs(xDistance) < abs(minDistance)) {
                minDistance = xDistance
            }
        }
        scrollView.isUserInteractionEnabled = false
        scrollView.setContentOffset(CGPoint(x: scrollView.contentOffset.x + minDistance, y: scrollView.contentOffset.y), animated: true)
        
        fadeInTimeLabels()
    }
}

protocol LevelPickerViewControllerDelegate {
    func pickedLevel(_ levelId: String)
}
