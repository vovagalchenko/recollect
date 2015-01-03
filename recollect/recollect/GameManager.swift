//
//  GameManager.swift
//  recollect
//
//  Created by Vova Galchenko on 12/29/14.
//  Copyright (c) 2014 Vova Galchenko. All rights reserved.
//

import Foundation

class GameManager: GameplayInputControllerDelegate {
    
    class var sharedInstance : GameManager {
        struct Static {
            static let instance : GameManager = GameManager()
        }
        return Static.instance
    }
    
    class var gameLevels: [String] {
        return ["1", "2", "3", "4"]
    }
    
    class var GameStateChangeNotificationName: String {
        return "GAME_STATE_CHANGED"
    }
    
    class var GameStateChangeUserInfoKey: NSString {
        return "change"
    }
    
    var currentGameState: GameState? {
        didSet {
            NSNotificationCenter.defaultCenter().postNotificationName(
                GameManager.GameStateChangeNotificationName,
                object: self,
                userInfo: [GameManager.GameStateChangeUserInfoKey: GameStateChange(oldGameState: oldValue, newGameState: currentGameState)])
        }
    }
    
    func startGame(gameLevelId: String) {
        assert(self.currentGameState == nil, "Can't start a game when one is already in progress!")
        self.currentGameState = GameState(n: gameLevelId.toInt()!, numRounds: 10)
    }
}

extension GameManager: GameplayInputControllerDelegate {
    func receivedInput(input: GameplayInput) {
        switch input {
            case GameplayInput.Back:
                currentGameState = nil
            case GameplayInput.Forward:
                currentGameState = currentGameState!.advance()
            case .Zero, .One, .Two, .Three, .Four, .Five, .Six, .Seven, .Eight, .Nine:
                currentGameState = currentGameState!.advance(userInput: input.rawValue)
            default:
                fatalError("Can't understand user input <\(input)>.")
        }
    }
}

extension GameManager: LevelPickerViewControllerDelegate {
    func pickedLevel(levelId: String) {
        GameManager.sharedInstance.startGame(levelId)
    }
}

class GameState: Streamable {
    let n: Int
    var challenges: [Challenge]
    var currentChallengeIndex: Int
    
    init(n: Int, numRounds: Int) {
        self.n = n
        
        var newChallenges: [Challenge] = []
        for _ in 0..<numRounds {
            let lOperand = Int(arc4random_uniform(UInt32(9)))
            let rOperand = Int(arc4random_uniform(UInt32(9)))
            newChallenges.append(Challenge(left: lOperand, right: rOperand))
        }
        
        self.challenges = newChallenges
        currentChallengeIndex = -n
    }
    
    init(n: Int, challenges: [Challenge], currentChallengeIndex: Int) {
        self.n = n
        self.challenges = challenges
        self.currentChallengeIndex = currentChallengeIndex
    }
    
    func writeTo<Target : OutputStreamType>(inout target: Target) {
        target.write("GAME STATE:\n\tn = \(n)\n\tchallenges = \(challenges)\n\tcurrentChallengeIndex = \(currentChallengeIndex)")
    }
    
    func advance(userInput: Int? = nil) -> GameState {
        
        if let givenUserInput = userInput {
            assert(currentChallengeIndex >= 0 && currentChallengeIndex < challenges.count,
                "User gave input for a bogus challenge index: \(currentChallengeIndex)")
            let (shouldAdvance, newChallenge) = challenges[currentChallengeIndex].respond(givenUserInput)
            var mutableChallenges = challenges
            mutableChallenges[currentChallengeIndex] = newChallenge
            return GameState(n: n, challenges: mutableChallenges, currentChallengeIndex: shouldAdvance ? currentChallengeIndex + 1 : currentChallengeIndex)
        } else {
            assert(currentChallengeIndex < 0,
                "User should not be able to advance without giving a response to a valid challenge at index \(currentChallengeIndex)")
            return GameState(n: n, challenges: challenges, currentChallengeIndex: currentChallengeIndex + 1)
        }
    }
}

class GameStateChange {
    let oldGameState: GameState?
    let newGameState: GameState?
    
    init(oldGameState: GameState? = nil, newGameState: GameState? = nil) {
        self.oldGameState = oldGameState
        self.newGameState = newGameState
    }
}

class Challenge: Streamable {
    let lOperand: Int
    let rOperand: Int
    let challengeOperator: ChallengeOperator = ChallengeOperator.Sum
    var userResponses: [Int] = []
    
    init(left: Int, right: Int) {
        lOperand = left
        rOperand = right
    }
    
    init(left: Int, right: Int, userResponses: [Int]) {
        lOperand = left
        rOperand = right
        self.userResponses = userResponses
    }
    
    func respond(response: Int) -> (Bool, Challenge) {
        var newResponses = userResponses
        newResponses.append(response)
        return (challengeOperator.apply(lOperand, rOperand: rOperand) == response, Challenge(left: lOperand, right: rOperand, userResponses: newResponses))
    }
    
    func writeTo<Target : OutputStreamType>(inout target: Target) {
        target.write("\(lOperand) \(challengeOperator) \(rOperand)")
    }
}

enum ChallengeOperator: Streamable {
    case Sum
    
    func apply(lOperand: Int, rOperand: Int) -> Int {
        switch (self) {
            case .Sum: return (lOperand + rOperand) % 10
        }
    }
    
    func writeTo<Target : OutputStreamType>(inout target: Target) {
        switch (self) {
            case .Sum: target.write("+")
        }
    }
}
