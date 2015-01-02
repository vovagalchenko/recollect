//
//  ProgressViewController.swift
//  recollect
//
//  Created by Vova Galchenko on 1/1/15.
//  Copyright (c) 2015 Vova Galchenko. All rights reserved.
//

import UIKit

class ProgressViewController: UIViewController {
    
    private let dotsSpread: CGFloat = 80.0
    private let numRounds: Int = GameManager.numRounds
    private var timeLabel: ManglableLabel?
    private var dotViews: [UILabel] = [UILabel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.setTranslatesAutoresizingMaskIntoConstraints(false)
        view.backgroundColor = DesignLanguage.BottomHalfBGColor
        
        let font = UIFont(name: "AvenirNextCondensed-DemiBold", size: 25.0)
        timeLabel = ManglableLabel()
        timeLabel?.setTranslatesAutoresizingMaskIntoConstraints(false)
        timeLabel?.backgroundColor = UIColor.clearColor()
        timeLabel?.textColor = UIColor(red: 140.0/255.0, green: 147.0/255.0, blue: 148.0/255.0, alpha: 0.30)
        timeLabel?.font = font
        timeLabel?.text = "00:00:00"
        view.addSubview(timeLabel!)
        
        view.addConstraints(
            [
                NSLayoutConstraint(
                    item: timeLabel!,
                    attribute: NSLayoutAttribute.CenterX,
                    relatedBy: NSLayoutRelation.Equal,
                    toItem: view,
                    attribute: NSLayoutAttribute.CenterX,
                    multiplier: 1.0,
                    constant: 0.0),
                NSLayoutConstraint(
                    item: timeLabel!,
                    attribute: NSLayoutAttribute.CenterY,
                    relatedBy: NSLayoutRelation.Equal,
                    toItem: view,
                    attribute: NSLayoutAttribute.CenterY,
                    multiplier: 1.0,
                    constant: 0.0)
            ]
        )
        
        for i in 1...numRounds {
            let dotLabel = UILabel()
            dotLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
            dotLabel.backgroundColor = UIColor.clearColor()
            dotLabel.textColor = DesignLanguage.ActiveTextColor
            dotLabel.font = font
            dotLabel.text = "."
            view.addSubview(dotLabel)
            dotViews.append(dotLabel)
            
            view.addConstraints(
                [
                    NSLayoutConstraint(
                        item: dotLabel,
                        attribute: NSLayoutAttribute.CenterX,
                        relatedBy: NSLayoutRelation.Equal,
                        toItem: view,
                        attribute: NSLayoutAttribute.CenterX,
                        multiplier: 1.0,
                        constant: -(dotsSpread/2.0) + ((dotsSpread*CGFloat(i - 1))/CGFloat(numRounds - 1))),
                    NSLayoutConstraint(
                        item: dotLabel,
                        attribute: NSLayoutAttribute.CenterY,
                        relatedBy: NSLayoutRelation.Equal,
                        toItem: view,
                        attribute: NSLayoutAttribute.Bottom,
                        multiplier: 0.70,
                        constant: 0)
                ]
            )
        }
        
        let dispatchTime = dispatch_time(
            DISPATCH_TIME_NOW,
            Int64(5.0 * Double(NSEC_PER_SEC))
        )
        
        let bottomShadow = UIView()
        bottomShadow.setTranslatesAutoresizingMaskIntoConstraints(false)
        bottomShadow.backgroundColor = DesignLanguage.ShadowColor
        view.addSubview(bottomShadow)
        
        view.addConstraints(
            NSLayoutConstraint.constraintsWithVisualFormat(
                "H:|[bottomShadow]|",
                options: NSLayoutFormatOptions(0),
                metrics: nil,
                views: ["bottomShadow" : bottomShadow]) +
            NSLayoutConstraint.constraintsWithVisualFormat(
                "V:[bottomShadow(1)]|",
                options: NSLayoutFormatOptions(0),
                metrics: nil,
                views: ["bottomShadow" : bottomShadow])
        )
    }
}
