//
//  GameState.swift
//  recollect
//
//  Created by Vova Galchenko on 1/3/15.
//  Copyright (c) 2015 Vova Galchenko. All rights reserved.
//

import Foundation

class GameState: Streamable {
    let n: Int
    var challenges: [Challenge]
    var currentChallengeIndex: Int
    var timeStart: NSDate?
    
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
    
    init(n: Int, challenges: [Challenge], currentChallengeIndex: Int, timeStart: NSDate?) {
        self.n = n
        self.challenges = challenges
        self.currentChallengeIndex = currentChallengeIndex
        self.timeStart = timeStart
    }
    
    func advance(userInput: Int? = nil) -> GameState {
        
        if let givenUserInput = userInput {
            assert(currentChallengeIndex >= 0 && currentChallengeIndex < challenges.count,
                "User gave input for a bogus challenge index: \(currentChallengeIndex)")
            let (shouldAdvance, newChallenge) = challenges[currentChallengeIndex].respond(givenUserInput)
            var mutableChallenges = challenges
            mutableChallenges[currentChallengeIndex] = newChallenge
            return GameState(
                n: n,
                challenges: mutableChallenges,
                currentChallengeIndex: shouldAdvance ? currentChallengeIndex + 1 : currentChallengeIndex,
                timeStart: timeStart
            )
        } else {
            assert(currentChallengeIndex < 0,
                "User should not be able to advance without giving a response to a valid challenge at index \(currentChallengeIndex)")
            return GameState(n: n, challenges: challenges, currentChallengeIndex: currentChallengeIndex + 1, timeStart: (currentChallengeIndex + 1 == 0) ? NSDate() : timeStart)
        }
    }
    
    func writeTo<Target : OutputStreamType>(inout target: Target) {
        target.write("GAME STATE:\n\tn = \(n)\n\tchallenges = \(challenges)\n\tcurrentChallengeIndex = \(currentChallengeIndex)")
    }
}

@objc class GameStateChange {
    let oldGameState: GameState?
    let newGameState: GameState?
    
    init(oldGameState: GameState? = nil, newGameState: GameState? = nil) {
        self.oldGameState = oldGameState
        self.newGameState = newGameState
    }
}
