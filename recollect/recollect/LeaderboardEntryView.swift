//
//  PlayerScoreView.swift
//  recollect
//
//  Created by Vova Galchenko on 5/17/15.
//  Copyright (c) 2015 Vova Galchenko. All rights reserved.
//

import UIKit

enum LeaderboardEntryViewPosition {
    case Top, Middle, Bottom, Gap
}

class LeaderboardEntryView: UIView {
    private var rankLabel: ManglableLabel!
    private var nameLabel: ManglableLabel!
    private var timeLabel: ManglableLabel!
    private var avatarImageView: UIImageView!
    private let position: LeaderboardEntryViewPosition
    var rank: Int {
        get {
            return Int(rankLabel.text!)!
        }
    }
    
    init(pos: LeaderboardEntryViewPosition = .Middle) {
        position = pos
        super.init(frame: CGRectZero)
        backgroundColor = UIColor.clearColor()
        translatesAutoresizingMaskIntoConstraints = false
        
        rankLabel = createLabel()
        nameLabel = createLabel()
        timeLabel = createLabel()
        avatarImageView = UIImageView(image: UIImage(named: "default_avatar"))
        avatarImageView.layer.borderColor = DesignLanguage.NeverActiveTextColor.CGColor
        avatarImageView.layer.borderWidth = 1.0
        avatarImageView.layer.masksToBounds = true
        avatarImageView.contentMode = UIViewContentMode.ScaleAspectFill
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        avatarImageView.alpha = 0.0
        let padding: CGFloat = 15.0
        for subview in [rankLabel, nameLabel, timeLabel, avatarImageView] {
            addSubview(subview)
            addConstraints(
                NSLayoutConstraint.constraintsWithVisualFormat(
                    "V:|-(\(padding/2.0))-[subview]-(\(padding/2.0))-|",
                    options: NSLayoutFormatOptions(rawValue: 0),
                    metrics: nil,
                    views: ["subview": subview])
            )
        }
        
        addConstraints(
            NSLayoutConstraint.constraintsWithVisualFormat(
                "H:|-(\(padding))-[rank]-(\(padding))-[avatar]-(\(padding))-[name]",
                options: NSLayoutFormatOptions(rawValue: 0),
                metrics: nil,
                views: ["rank": rankLabel, "avatar": avatarImageView, "name": nameLabel]) +
            NSLayoutConstraint.constraintsWithVisualFormat(
                "H:[timeLabel]-(\(padding))-|",
                options: NSLayoutFormatOptions(rawValue: 0),
                metrics: nil,
                views: ["timeLabel": timeLabel])
        )
        addConstraint(
            NSLayoutConstraint(
                item: avatarImageView,
                attribute: .Height,
                relatedBy: .Equal,
                toItem: avatarImageView,
                attribute: .Width,
                multiplier: 1.0,
                constant: 0.0)
        )
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        avatarImageView.layer.cornerRadius = avatarImageView.bounds.size.height/2.0
        setNeedsDisplay()
    }
    
    func setLeaderboardEntry(entry: LeaderboardEntry) {
        nameLabel.text = entry.playerName
        rankLabel.text = "\(entry.rank)"
        timeLabel.text = entry.time.minuteSecondCentisecondString()
        avatarImageView.alpha = 1.0
        
        let labels = [nameLabel, rankLabel, timeLabel]
        for label in labels {
            if entry.playerId == PlayerIdentityManager.sharedInstance.currentIdentity.playerId {
                label.textColor = DesignLanguage.ActiveTextColor
            } else {
                label.textColor = DesignLanguage.NeverActiveTextColor
            }
        }
    }
    
    private func createLabel() -> ManglableLabel {
        let label = ManglableLabel()
        label.backgroundColor = UIColor.clearColor()
        label.font = UIFont(name: "AvenirNextCondensed-Regular", size: 20.0)
        label.textColor = DesignLanguage.NeverActiveTextColor
        return label
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func drawRect(rect: CGRect) {
        let ctx = UIGraphicsGetCurrentContext()
        
        if position == .Gap {
            DesignLanguage.ShadowColor.setFill()
            CGContextFillRect(ctx, bounds)
        } else {
            let (points, _) = pixelPerfectCoordinates(
                thicknessInPixels: 1,
                points: CGPoint(x: 0, y: 0),
                CGPoint(x: bounds.size.width, y: 0),
                CGPoint(x: 0, y: bounds.size.height),
                CGPoint(x: bounds.size.width, y: bounds.size.height)
            )
            
            if position != .Top {
                CGContextMoveToPoint(ctx, points[0].x, points[0].y)
                CGContextAddLineToPoint(ctx, points[1].x, points[1].y)
                
                DesignLanguage.HighlightColor.setStroke()
                CGContextDrawPath(ctx, CGPathDrawingMode.Stroke)
            }
            if position != .Bottom {
                CGContextMoveToPoint(ctx, points[2].x, points[2].y)
                CGContextAddLineToPoint(ctx, points[3].x, points[3].y)
                
                DesignLanguage.ShadowColor.setStroke()
                CGContextDrawPath(ctx, CGPathDrawingMode.Stroke)
            }
        }
    }
    
    override class func requiresConstraintBasedLayout() -> Bool { return true }
}
