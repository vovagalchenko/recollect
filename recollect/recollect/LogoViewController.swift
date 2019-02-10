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
                attribute: NSLayoutConstraint.Attribute.centerX,
                relatedBy: NSLayoutConstraint.Relation.equal,
                toItem: view,
                attribute: NSLayoutConstraint.Attribute.centerX,
                multiplier: 1.0,
                constant: 0.0
            ),
            NSLayoutConstraint(
                item: logoContainer,
                attribute: NSLayoutConstraint.Attribute.centerY,
                relatedBy: NSLayoutConstraint.Relation.equal,
                toItem: view,
                attribute: NSLayoutConstraint.Attribute.centerY,
                multiplier: 1.0,
                constant: 0.0
            ),
            NSLayoutConstraint(
                item: logoContainer,
                attribute: NSLayoutConstraint.Attribute.width,
                relatedBy: NSLayoutConstraint.Relation.equal,
                toItem: view,
                attribute: NSLayoutConstraint.Attribute.width,
                multiplier: 0.5,
                constant: 0.0
            ),
            NSLayoutConstraint(
                item: logoContainer,
                attribute: NSLayoutConstraint.Attribute.height,
                relatedBy: NSLayoutConstraint.Relation.equal,
                toItem: view,
                attribute: NSLayoutConstraint.Attribute.height,
                multiplier: 0.5,
                constant: 0.0
            )
        ])

        
        for (lineIndex, line) in logoText.enumerated() {
            assert(line.lengthOfBytes(using: String.Encoding.utf8) == self.logoText.count, "The logo text must be such that it forms a perfect square")
            for (index, character) in line.enumerated() {
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
                        attribute: NSLayoutConstraint.Attribute.centerX,
                        relatedBy: NSLayoutConstraint.Relation.equal,
                        toItem: logoContainer,
                        attribute: NSLayoutConstraint.Attribute.centerX,
                        multiplier: CGFloat((2.0/(Float(line.lengthOfBytes(using: String.Encoding.ascii)) + 1.0)) * Float(index + 1)),
                        constant: 0.0
                    ),
                    NSLayoutConstraint(
                        item: characterView,
                        attribute: NSLayoutConstraint.Attribute.centerY,
                        relatedBy: NSLayoutConstraint.Relation.equal,
                        toItem: logoContainer,
                        attribute: NSLayoutConstraint.Attribute.centerY,
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
