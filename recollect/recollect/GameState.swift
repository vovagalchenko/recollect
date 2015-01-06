//
//  GameState.swift
//  recollect
//
//  Created by Vova Galchenko on 1/3/15.
//  Copyright (c) 2015 Vova Galchenko. All rights reserved.
//

import Foundation

final class GameState: Streamable {
    let n: Int
    var levelId: String {
        return "\(n)"
    }
    var challenges: [Challenge]
    var currentChallengeIndex: Int
    var closedTimeIntervals: [TimeInterval]
    var latestTimeStart: NSDate?
    
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
        closedTimeIntervals = []
    }
    
    init(n: Int, challenges: [Challenge], currentChallengeIndex: Int, closedTimeIntervals: [TimeInterval], latestTimeStart: NSDate?) {
        self.n = n
        self.challenges = challenges
        self.currentChallengeIndex = currentChallengeIndex
        self.closedTimeIntervals = closedTimeIntervals
        self.latestTimeStart = latestTimeStart
        
        if currentChallengeIndex > self.challenges.count && latestTimeStart != nil {
            self.stop()
        }
    }
    
    func stop() {
        assert(latestTimeStart != nil, "Can't stop a game that's not started.")
        closedTimeIntervals.append(TimeInterval(startTime: latestTimeStart!, endTime: NSDate()))
        latestTimeStart = nil
    }
    
    func advance(userInput: Int? = nil) -> GameState {
        
        if let givenUserInput = userInput {
            assert(currentChallengeIndex >= 0 && currentChallengeIndex < challenges.count,
                "User gave input for a bogus challenge index: \(currentChallengeIndex)")
            let (shouldAdvance, fulfilledChallenge) = challenges[currentChallengeIndex].respond(givenUserInput)
            var mutableChallenges = challenges
            mutableChallenges[currentChallengeIndex] = fulfilledChallenge
            return GameState(
                n: n,
                challenges: mutableChallenges,
                currentChallengeIndex: shouldAdvance ? currentChallengeIndex + 1 : currentChallengeIndex,
                closedTimeIntervals: closedTimeIntervals,
                latestTimeStart: latestTimeStart
            )
        } else {
            assert(currentChallengeIndex < 0,
                "User should not be able to advance without giving a response to a valid challenge at index \(currentChallengeIndex)")
            return GameState(
                n: n,
                challenges: challenges,
                currentChallengeIndex: currentChallengeIndex + 1,
                closedTimeIntervals: closedTimeIntervals,
                latestTimeStart: (currentChallengeIndex + 1 == 0) ? NSDate() : latestTimeStart)
        }
    }
    
    func time(atTime time: NSDate = NSDate()) -> NSTimeInterval {
        let closedIntervalTime = closedTimeIntervals.reduce(0) { $0.0 + $0.1.duration() }
        if let currentTimeIntervalStart = latestTimeStart {
            return closedIntervalTime + time.timeIntervalSinceDate(currentTimeIntervalStart)
        } else {
            return closedIntervalTime
        }
    }
    
    func finalTime() -> NSTimeInterval {
        assert(latestTimeStart == nil, "Can't get the final time while the game is still in progress.")
        return time()
    }
    
    func writeTo<Target : OutputStreamType>(inout target: Target) {
        target.write("GAME STATE:\n\tn = \(n)\n\tchallenges = \(challenges)\n\tcurrentChallengeIndex = \(currentChallengeIndex)")
    }
}

final class TimeInterval {
    let startTime: NSDate
    let endTime: NSDate
    
    init(startTime: NSDate, endTime: NSDate) {
        self.startTime = startTime
        self.endTime = endTime
    }
    
    func duration() -> NSTimeInterval {
        return endTime.timeIntervalSinceDate(startTime)
    }
}

extension GameState: NSCoding {
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeInteger(n, forKey: "n")
        aCoder.encodeObject(challenges, forKey: "challenges")
        aCoder.encodeInteger(currentChallengeIndex, forKey: "currentChallengeIndex")
        aCoder.encodeObject(closedTimeIntervals, forKey: "closedTimeIntervals")
        if let currentTimeIntervalStart = latestTimeStart {
            aCoder.encodeObject(currentTimeIntervalStart, forKey: "latestTimeStart")
        }
    }
    
    convenience init(coder aDecoder: NSCoder) {
        let newN = aDecoder.decodeIntegerForKey("n")
        let newChallenges = aDecoder.decodeObjectForKey("challenges") as [Challenge]
        let newCurrentChallengeIndex = aDecoder.decodeIntegerForKey("currentChallengeIndex")
        let newClosedTimeIntervals = aDecoder.decodeObjectForKey("closedTimeIntervals") as [TimeInterval]
        let newLatestTimeStart = aDecoder.containsValueForKey("latestTimeStart") ? aDecoder.decodeObjectForKey("latestTimeStart") as NSDate? : nil
        
        self.init(
            n: newN,
            challenges: newChallenges,
            currentChallengeIndex: newCurrentChallengeIndex,
            closedTimeIntervals: newClosedTimeIntervals,
            latestTimeStart: newLatestTimeStart
        )
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
