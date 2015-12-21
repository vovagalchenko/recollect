//
//  GameplayInputController.swift
//  recollect
//
//  Created by Vova Galchenko on 12/31/14.
//  Copyright (c) 2014 Vova Galchenko. All rights reserved.
//

import UIKit

class GameplayInputController: HalfScreenViewController {
    
    let delegate: GameplayInputControllerDelegate
    let buttonsText = [
        ["1", "2", "3"],
        ["4", "5", "6"],
        ["7", "8", "9"],
        ["«", "0", "»"]
    ]
    var buttons: [GameplayButton] = []
    
    init(delegate: GameplayInputControllerDelegate) {
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) won't be implemented because I ain't using xibs")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for (lineNumber, buttonTextLine) in buttonsText.enumerate() {
            for (buttonNumber, buttonText) in buttonTextLine.enumerate() {
                let button = gameplayButton(buttonText)
                buttons.append(button)
                if Int(buttonText) != nil {
                    button.enabled = false
                }
                view.addSubview(button)
                
                view.addConstraints(
                    [
                        NSLayoutConstraint(
                            item: button,
                            attribute: NSLayoutAttribute.CenterX,
                            relatedBy: NSLayoutRelation.Equal,
                            toItem: view,
                            attribute: NSLayoutAttribute.CenterX,
                            multiplier: CGFloat((2.0/(CGFloat(buttonTextLine.count)*2)) * CGFloat(buttonNumber*2 + 1)),
                            constant: 0.0
                        ),
                        NSLayoutConstraint(
                            item: button,
                            attribute: NSLayoutAttribute.CenterY,
                            relatedBy: NSLayoutRelation.Equal,
                            toItem: view,
                            attribute: NSLayoutAttribute.CenterY,
                            multiplier: CGFloat((2.0/(CGFloat(buttonsText.count)*2)) * CGFloat(lineNumber*2 + 1)),
                            constant: 0.0
                        ),
                        NSLayoutConstraint(
                            item: button,
                            attribute: NSLayoutAttribute.Height,
                            relatedBy: NSLayoutRelation.Equal,
                            toItem: view,
                            attribute: NSLayoutAttribute.Height,
                            multiplier: CGFloat(1.0)/CGFloat(buttonsText.count),
                            constant: 0.0
                        ),
                        NSLayoutConstraint(
                            item: button,
                            attribute: NSLayoutAttribute.Width,
                            relatedBy: NSLayoutRelation.Equal,
                            toItem: view,
                            attribute: NSLayoutAttribute.Width,
                            multiplier: CGFloat(1.0)/CGFloat(buttonTextLine.count),
                            constant: 0.0
                        )
                    ]
                )
            }
        }
        
        GameManager.sharedInstance.subscribeToGameStateChangeNotifications(self)
    }
    
    deinit {
        GameManager.sharedInstance.unsubscribeFromGameStateChangeNotifications(self)
    }
    
    func handleButtonPress(gameplayButton: GameplayButton) {
        delegate.receivedInput(GameplayInput.fromString(gameplayButton.text))
    }
    
    private func gameplayButton(text: String) -> GameplayButton {
        let button = GameplayButton()
        button.addTarget(self, action: "handleButtonPress:", forControlEvents: UIControlEvents.TouchUpInside)
        button.text = text
        button.glowWhenEnabled = text == "»"
        return button
    }
}

extension GameplayInputController: GameStateChangeListener {
    func gameStateChanged(change: GameStateChange) {
        if (change.oldGameState?.currentChallengeIndex ?? Int.min) < 0 &&
            (change.newGameState?.currentChallengeIndex ?? Int.min) >= 0 {
                for button in self.buttons {
                    button.enabled = (button.text != "»")
                }
        }
    }
}

enum GameplayInput: Int, CustomStringConvertible {
    case Zero, One, Two, Three, Four, Five, Six, Seven, Eight, Nine, Back, Forward
    
    var description: String {
        get {
            switch self {
            case Zero, One, Two, Three, Four, Five, Six, Seven, Eight, Nine: return "\(rawValue)"
            case Back: return "back"
            case Forward: return "forward"
            }
        }
    }
    
    static func fromString(str: String) -> GameplayInput {
        switch(str) {
            case "0", "1", "2", "3", "4", "5", "6", "7", "8", "9": return GameplayInput(rawValue: Int(str)!)!
            case "«": return GameplayInput.Back
            case "»": return GameplayInput.Forward
            default: fatalError("Unexpected string to create a GameplayInput from: \(str)")
        }
    }
}

protocol GameplayInputControllerDelegate {
    func receivedInput(input: GameplayInput)
}