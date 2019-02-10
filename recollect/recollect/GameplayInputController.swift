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
        
        for (lineNumber, buttonTextLine) in buttonsText.enumerated() {
            for (buttonNumber, buttonText) in buttonTextLine.enumerated() {
                let button = gameplayButton(buttonText)
                buttons.append(button)
                if Int(buttonText) != nil {
                    button.isEnabled = false
                }
                view.addSubview(button)
                
                view.addConstraints(
                    [
                        NSLayoutConstraint(
                            item: button,
                            attribute: NSLayoutConstraint.Attribute.centerX,
                            relatedBy: NSLayoutConstraint.Relation.equal,
                            toItem: view,
                            attribute: NSLayoutConstraint.Attribute.centerX,
                            multiplier: CGFloat((2.0/(CGFloat(buttonTextLine.count)*2)) * CGFloat(buttonNumber*2 + 1)),
                            constant: 0.0
                        ),
                        NSLayoutConstraint(
                            item: button,
                            attribute: NSLayoutConstraint.Attribute.centerY,
                            relatedBy: NSLayoutConstraint.Relation.equal,
                            toItem: view,
                            attribute: NSLayoutConstraint.Attribute.centerY,
                            multiplier: CGFloat((2.0/(CGFloat(buttonsText.count)*2)) * CGFloat(lineNumber*2 + 1)),
                            constant: 0.0
                        ),
                        NSLayoutConstraint(
                            item: button,
                            attribute: NSLayoutConstraint.Attribute.height,
                            relatedBy: NSLayoutConstraint.Relation.equal,
                            toItem: view,
                            attribute: NSLayoutConstraint.Attribute.height,
                            multiplier: CGFloat(1.0)/CGFloat(buttonsText.count),
                            constant: 0.0
                        ),
                        NSLayoutConstraint(
                            item: button,
                            attribute: NSLayoutConstraint.Attribute.width,
                            relatedBy: NSLayoutConstraint.Relation.equal,
                            toItem: view,
                            attribute: NSLayoutConstraint.Attribute.width,
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
    
    @objc func handleButtonPress(_ gameplayButton: GameplayButton) {
        delegate.receivedInput(GameplayInput.fromString(gameplayButton.text))
    }
    
    private func gameplayButton(_ text: String) -> GameplayButton {
        let button = GameplayButton()
        button.addTarget(self, action: #selector(GameplayInputController.handleButtonPress(_:)), for: UIControl.Event.touchUpInside)
        button.text = text
        button.glowWhenEnabled = text == "»"
        return button
    }
}

extension GameplayInputController: GameStateChangeListener {
    func gameStateChanged(_ change: GameStateChange) {
        if (change.oldGameState?.currentChallengeIndex ?? Int.min) < 0 &&
            (change.newGameState?.currentChallengeIndex ?? Int.min) >= 0 {
                for button in self.buttons {
                    button.isEnabled = (button.text != "»")
                }
        }
    }
}

enum GameplayInput: Int, CustomStringConvertible {
    case zero, one, two, three, four, five, six, seven, eight, nine, back, forward
    
    var description: String {
        get {
            switch self {
            case .zero, .one, .two, .three, .four, .five, .six, .seven, .eight, .nine: return "\(rawValue)"
            case .back: return "back"
            case .forward: return "forward"
            }
        }
    }
    
    static func fromString(_ str: String) -> GameplayInput {
        switch(str) {
            case "0", "1", "2", "3", "4", "5", "6", "7", "8", "9": return GameplayInput(rawValue: Int(str)!)!
            case "«": return GameplayInput.back
            case "»": return GameplayInput.forward
            default: fatalError("Unexpected string to create a GameplayInput from: \(str)")
        }
    }
}

protocol GameplayInputControllerDelegate {
    func receivedInput(_ input: GameplayInput)
}
