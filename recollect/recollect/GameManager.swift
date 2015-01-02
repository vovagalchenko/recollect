//
//  GameManager.swift
//  recollect
//
//  Created by Vova Galchenko on 12/29/14.
//  Copyright (c) 2014 Vova Galchenko. All rights reserved.
//

class GameManager: GameplayInputControllerDelegate {
    class var gameLevels: [String] {
        return ["1", "2", "3", "4"]
    }
    
    class var numRounds: Int {
        return 10
    }
    
    let gameLevelId: String
    let gameInputController: GameplayInputController
    weak var baseController: BaseViewController?
    
    init(gameLevelId: String, baseController: BaseViewController) {
        self.gameLevelId = gameLevelId
        self.gameInputController = GameplayInputController()
        self.baseController = baseController
        
        gameInputController.delegate = self
    }
    
    func startGame() {
        baseController?.queueTransition(newTopViewControllerFunc: { return GameplayOutputViewController() }, newBottomViewControllerFunc: {
            let gameplayInputController = GameplayInputController()
            gameplayInputController.delegate = self
            return gameplayInputController
        })
    }
    
    func stopGame() {
        baseController?.queueTransition(newTopViewControllerFunc: { return LogoViewController() }, newBottomViewControllerFunc: {
            let levelPicker = LevelPickerViewController()
            levelPicker.delegate = self.baseController
            return levelPicker
        })
    }
    
    func receivedInput(input: GameplayInput) {
        if (input == GameplayInput.Back) {
            stopGame()
        }
    }
}
