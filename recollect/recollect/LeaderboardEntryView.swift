//
//  PlayerScoreView.swift
//  recollect
//
//  Created by Vova Galchenko on 5/17/15.
//  Copyright (c) 2015 Vova Galchenko. All rights reserved.
//

import UIKit

enum LeaderboardEntryViewPosition {
    case top, middle, bottom, gap
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
    var playerId: String?
    
    init(pos: LeaderboardEntryViewPosition = .middle) {
        position = pos
        super.init(frame: CGRect.zero)
        backgroundColor = UIColor.clear
        translatesAutoresizingMaskIntoConstraints = false
        
        rankLabel = createLabel()
        nameLabel = createLabel()
        timeLabel = createLabel()
        avatarImageView = UIImageView(image: UIImage(named: "default_avatar"))
        avatarImageView.layer.borderColor = DesignLanguage.NeverActiveTextColor.cgColor
        avatarImageView.layer.borderWidth = 1.0
        avatarImageView.layer.masksToBounds = true
        avatarImageView.contentMode = UIViewContentMode.scaleAspectFill
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        avatarImageView.alpha = 0.0
        let padding: CGFloat = 15.0
        for subview in [rankLabel, nameLabel, timeLabel, avatarImageView] as [Any] {
            addSubview(subview as! UIView)
            addConstraints(
                NSLayoutConstraint.constraints(
                    withVisualFormat: "V:|-(\(padding/2.0))-[subview]-(\(padding/2.0))-|",
                    options: NSLayoutFormatOptions(rawValue: 0),
                    metrics: nil,
                    views: ["subview": subview])
            )
        }
        
        addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "H:|-(\(padding))-[rank]-(\(padding))-[avatar]-(\(padding))-[name]",
                options: NSLayoutFormatOptions(rawValue: 0),
                metrics: nil,
                views: ["rank": rankLabel, "avatar": avatarImageView, "name": nameLabel]) +
            NSLayoutConstraint.constraints(
                withVisualFormat: "H:[timeLabel]-(\(padding))-|",
                options: NSLayoutFormatOptions(rawValue: 0),
                metrics: nil,
                views: ["timeLabel": timeLabel])
        )
        addConstraint(
            NSLayoutConstraint(
                item: avatarImageView,
                attribute: .height,
                relatedBy: .equal,
                toItem: avatarImageView,
                attribute: .width,
                multiplier: 1.0,
                constant: 0.0)
        )
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        avatarImageView.layer.cornerRadius = avatarImageView.bounds.size.height/2.0
        setNeedsDisplay()
    }
    
    func setLeaderboardEntry(_ entry: LeaderboardEntry) {
        nameLabel.text = entry.playerName
        rankLabel.text = "\(entry.rank)"
        timeLabel.text = entry.time.minuteSecondCentisecondString()
        playerId = entry.playerId
        avatarImageView.alpha = 1.0
        
        let labels = [nameLabel, rankLabel, timeLabel]
        for label in labels {
            if entry.playerId == PlayerIdentityManager.sharedInstance.currentIdentity.playerId {
                label?.textColor = DesignLanguage.ActiveTextColor
            } else {
                label?.textColor = DesignLanguage.NeverActiveTextColor
            }
        }
    }
    
    func setAvatarImage(_ image: UIImage) {
        avatarImageView.image = image
    }
    
    private func createLabel() -> ManglableLabel {
        let label = ManglableLabel()
        label.backgroundColor = UIColor.clear
        label.font = UIFont(name: "AvenirNextCondensed-Regular", size: 20.0)
        label.textColor = DesignLanguage.NeverActiveTextColor
        return label
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        let ctx = UIGraphicsGetCurrentContext()
        
        if position == .gap {
            DesignLanguage.ShadowColor.setFill()
            ctx?.fill(bounds)
        } else {
            let (points, _) = pixelPerfectCoordinates(
                thicknessInPixels: 1,
                points: CGPoint(x: 0, y: 0),
                CGPoint(x: bounds.size.width, y: 0),
                CGPoint(x: 0, y: bounds.size.height),
                CGPoint(x: bounds.size.width, y: bounds.size.height)
            )
            
            if position != .top {
                ctx?.move(to: CGPoint(x: points[0].x, y: points[0].y))
                ctx?.addLine(to: CGPoint(x: points[1].x, y: points[1].y))
                
                DesignLanguage.HighlightColor.setStroke()
                ctx?.drawPath(using: CGPathDrawingMode.stroke)
            }
            if position != .bottom {
                ctx?.move(to: CGPoint(x: points[2].x, y: points[2].y))
                ctx?.addLine(to: CGPoint(x: points[3].x, y: points[3].y))
                
                DesignLanguage.ShadowColor.setStroke()
                ctx?.drawPath(using: CGPathDrawingMode.stroke)
            }
        }
    }
    
    override class var requiresConstraintBasedLayout : Bool { return true }
}
