//
//  LevelPickerViewController.swift
//  recollect
//
//  Created by Vova Galchenko on 12/27/14.
//  Copyright (c) 2014 Vova Galchenko. All rights reserved.
//

import UIKit

class LevelPickerViewController: HalfScreenViewController, UIGestureRecognizerDelegate {
    
    let horizontalPadding: CGFloat = 50
    let verticalPadding: CGFloat = 20
    var scrollView: UIScrollView!
    
    let delegate: LevelPickerViewControllerDelegate
    
    init(delegate: LevelPickerViewControllerDelegate) {
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }
    
    deinit {
        scrollView.delegate = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let swipeLabel = instructionsLabel()
        swipeLabel.text = "SWIPE TO CHOOSE A LEVEL."
        view.addSubview(swipeLabel)
        
        let tapLabel = instructionsLabel()
        tapLabel.text = "TAP TO START."
        view.addSubview(tapLabel)
        
        scrollView = UIScrollView()
        scrollView.delegate = self
        scrollView.setTranslatesAutoresizingMaskIntoConstraints(false)
        scrollView.alwaysBounceHorizontal = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        view.addSubview(scrollView)
        view.bringSubviewToFront(scrollView)
        let scrollViewConstraints =
            NSLayoutConstraint.constraintsWithVisualFormat(
                "H:|[scrollView]|",
                options: NSLayoutFormatOptions(0),
                metrics: nil,
                views: ["scrollView": scrollView]) +
            NSLayoutConstraint.constraintsWithVisualFormat(
                "V:|[scrollView]|",
                options: NSLayoutFormatOptions(0),
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
        
        var levelLabelConstraints = [AnyObject]()
        var labelsDict = [String: ManglableLabel]()
        for (index, (labelName, label)) in enumerate(levelLabels) {
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
            options: NSLayoutFormatOptions(0),
            metrics: nil,
            views: labelsDict as [NSObject: AnyObject])
        
        let allConstraints =
            NSLayoutConstraint.constraintsWithVisualFormat(
                "V:|-(\(verticalPadding))-[swipeLabel][tapLabel]",
                options: NSLayoutFormatOptions(0),
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
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: "handleTap:")
        tapRecognizer.numberOfTapsRequired = 1
        tapRecognizer.enabled = true
        tapRecognizer.cancelsTouchesInView = true
        tapRecognizer.delegate = self
        scrollView.addGestureRecognizer(tapRecognizer)
        
        view.setNeedsLayout()
        view.layoutIfNeeded()
        scrollViewDidScroll(scrollView)
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func handleTap(tapRecognizer: UITapGestureRecognizer) {
        let scrollView = tapRecognizer.view! as UIScrollView
        var minDistance = CGFloat.max
        var labelClosestToCenter: ManglableLabel? = nil
        for label in scrollView.subviews {
            let labelCenter = CGPointMake(label.center.x - scrollView.contentOffset.x, label.center.y)
            let xDistance = labelCenter.x - scrollView.center.x
            if (abs(xDistance) < abs(minDistance)) {
                minDistance = xDistance
                labelClosestToCenter = label as? ManglableLabel
            }
        }
        
        delegate.pickedLevel(labelClosestToCenter!.text!)
    }
    
    private func instructionsLabel() -> ManglableLabel {
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
    
    /*
    func scrollViewWillBeginDecelerating(scrollView: UIScrollView) {
        snapToNearestLevelLabel(scrollView)
    }*/
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if (!decelerate) {
            snapToNearestLevelLabel(scrollView)
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
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
                    red: interpolate(xDistance, inactiveR, activeR),
                    green: interpolate(xDistance, inactiveG, activeG),
                    blue: interpolate(xDistance, inactiveB, activeB),
                    alpha: 1.0)
            }
        }
    }
    
    func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
        scrollView.userInteractionEnabled = true
    }
    
    private func snapToNearestLevelLabel(scrollView: UIScrollView) {
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
    }
}

protocol LevelPickerViewControllerDelegate {
    func pickedLevel(levelId: String)
}
