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
        logoContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(logoContainer)
        logoContainer.backgroundColor = UIColor.clear
        view.addConstraints([
            NSLayoutConstraint(
                item: logoContainer,
                attribute: NSLayoutAttribute.centerX,
                relatedBy: NSLayoutRelation.equal,
                toItem: view,
                attribute: NSLayoutAttribute.centerX,
                multiplier: 1.0,
                constant: 0.0
            ),
            NSLayoutConstraint(
                item: logoContainer,
                attribute: NSLayoutAttribute.centerY,
                relatedBy: NSLayoutRelation.equal,
                toItem: view,
                attribute: NSLayoutAttribute.centerY,
                multiplier: 1.0,
                constant: 0.0
            ),
            NSLayoutConstraint(
                item: logoContainer,
                attribute: NSLayoutAttribute.width,
                relatedBy: NSLayoutRelation.equal,
                toItem: view,
                attribute: NSLayoutAttribute.width,
                multiplier: 0.5,
                constant: 0.0
            ),
            NSLayoutConstraint(
                item: logoContainer,
                attribute: NSLayoutAttribute.height,
                relatedBy: NSLayoutRelation.equal,
                toItem: view,
                attribute: NSLayoutAttribute.height,
                multiplier: 0.5,
                constant: 0.0
            )
        ])

        
        for (lineIndex, line) in logoText.enumerated() {
            assert(line.lengthOfBytes(using: String.Encoding.utf8) == self.logoText.count, "The logo text must be such that it forms a perfect square")
            for (index, character) in line.characters.enumerated() {
                let characterView = ManglableLabel()
                characterView.backgroundColor = UIColor.clear
                characterView.textColor = DesignLanguage.NeverActiveTextColor
                characterView.textAlignment = NSTextAlignment.center
                characterView.font = logoFont(baseFontSize)
                characterView.text = "\(character)"
                logoContainer.addSubview(characterView)
                
                view.addConstraints([
                    NSLayoutConstraint(
                        item: characterView,
                        attribute: NSLayoutAttribute.centerX,
                        relatedBy: NSLayoutRelation.equal,
                        toItem: logoContainer,
                        attribute: NSLayoutAttribute.centerX,
                        multiplier: CGFloat((2.0/(Float(line.lengthOfBytes(using: String.Encoding.ascii)) + 1.0)) * Float(index + 1)),
                        constant: 0.0
                    ),
                    NSLayoutConstraint(
                        item: characterView,
                        attribute: NSLayoutAttribute.centerY,
                        relatedBy: NSLayoutRelation.equal,
                        toItem: logoContainer,
                        attribute: NSLayoutAttribute.centerY,
                        multiplier: CGFloat((2.0/(CGFloat(logoText.count) + 1.0)) * CGFloat(lineIndex + 1)),
                        constant: 0.0
                    )
                ])
            }
        }
    }
    
    private func logoFont(_ size: CGFloat) -> UIFont { return UIFont(name: "HelveticaNeue-Light", size: size)! }
    
    override func isPurelyDecorative() -> Bool { return true }

}
