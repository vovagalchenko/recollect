//
//  LogoViewController.swift
//  recollect
//
//  Created by Vova Galchenko on 12/24/14.
//  Copyright (c) 2014 Vova Galchenko. All rights reserved.
//

import UIKit

class LogoViewController: HalfScreenViewController {
    
    let logoText = ["REC", "OLL", "ECT"]
    var characterViewMatrix = [[UILabel]]()

    let baseFontSize: CGFloat = 35.0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let logoContainer = UIView()
        logoContainer.setTranslatesAutoresizingMaskIntoConstraints(false)
        view.addSubview(logoContainer)
        logoContainer.backgroundColor = UIColor.clearColor()
        view.addConstraints([
            NSLayoutConstraint(
                item: logoContainer,
                attribute: NSLayoutAttribute.CenterX,
                relatedBy: NSLayoutRelation.Equal,
                toItem: view,
                attribute: NSLayoutAttribute.CenterX,
                multiplier: 1.0,
                constant: 0.0
            ),
            NSLayoutConstraint(
                item: logoContainer,
                attribute: NSLayoutAttribute.CenterY,
                relatedBy: NSLayoutRelation.Equal,
                toItem: view,
                attribute: NSLayoutAttribute.CenterY,
                multiplier: 1.0,
                constant: 0.0
            ),
            NSLayoutConstraint(
                item: logoContainer,
                attribute: NSLayoutAttribute.Width,
                relatedBy: NSLayoutRelation.Equal,
                toItem: view,
                attribute: NSLayoutAttribute.Width,
                multiplier: 0.5,
                constant: 0.0
            ),
            NSLayoutConstraint(
                item: logoContainer,
                attribute: NSLayoutAttribute.Height,
                relatedBy: NSLayoutRelation.Equal,
                toItem: view,
                attribute: NSLayoutAttribute.Height,
                multiplier: 0.5,
                constant: 0.0
            )
        ])

        
        for (lineIndex, line) in enumerate(logoText) {
            assert(line.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) == self.logoText.count, "The logo text must be such that it forms a perfect square")
            for (index, character) in enumerate(line) {
                let characterView = ManglableLabel()
                characterView.backgroundColor = UIColor.clearColor()
                characterView.textColor = DesignLanguage.NeverActiveTextColor
                characterView.textAlignment = NSTextAlignment.Center
                characterView.font = logoFont(baseFontSize)
                characterView.text = "\(character)"
                characterView.setTranslatesAutoresizingMaskIntoConstraints(false);
                logoContainer.addSubview(characterView)
                
                view.addConstraints([
                    NSLayoutConstraint(
                        item: characterView,
                        attribute: NSLayoutAttribute.CenterX,
                        relatedBy: NSLayoutRelation.Equal,
                        toItem: logoContainer,
                        attribute: NSLayoutAttribute.CenterX,
                        multiplier: CGFloat((2.0/(Float(line.lengthOfBytesUsingEncoding(NSASCIIStringEncoding)) + 1.0)) * Float(index + 1)),
                        constant: 0.0
                    ),
                    NSLayoutConstraint(
                        item: characterView,
                        attribute: NSLayoutAttribute.CenterY,
                        relatedBy: NSLayoutRelation.Equal,
                        toItem: logoContainer,
                        attribute: NSLayoutAttribute.CenterY,
                        multiplier: CGFloat((2.0/(CGFloat(logoText.count) + 1.0)) * CGFloat(lineIndex + 1)),
                        constant: 0.0
                    )
                ])
            }
        }
    }
    
    private func logoFont(size: CGFloat) -> UIFont { return UIFont(name: "HelveticaNeue-Light", size: size)! }
    
    override func isPurelyDecorative() -> Bool { return true }

}
