//
//  GameState.swift
//  recollect
//
//  Created by Vova Galchenko on 1/3/15.
//  Copyright (c) 2015 Vova Galchenko. All rights reserved.
//

import Foundation

let penaltyPerPeek: NSTimeInterval = 5

final class GameState: NSObject, Streamable {
    let gameId: String
    let n: Int
    var levelId: String {
        return "\(n)"
    }
    let challenges: [Challenge]
    let currentChallengeIndex: Int
    let closedTimeIntervals: [TimeInterval]
    let latestTimeStart: NSDate?
    let peeks: [NSDate]
    
    init(n: Int, numRounds: Int) {
        gameId = NSUUID().UUIDString
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
        peeks = []
    }
    
    init(gameId: String, n: Int, challenges: [Challenge], currentChallengeIndex: Int, closedTimeIntervals: [TimeInterval], latestTimeStart: NSDate?, peeks: [NSDate]) {
        self.gameId = gameId
        self.n = n
        self.challenges = challenges
        self.currentChallengeIndex = currentChallengeIndex
        self.peeks = peeks
        
        if currentChallengeIndex >= self.challenges.count && latestTimeStart != nil {
            self.closedTimeIntervals = closedTimeIntervals + [TimeInterval(startTime: latestTimeStart!, endTime: NSDate())]
            self.latestTimeStart = nil
        } else {
            self.closedTimeIntervals = closedTimeIntervals
            self.latestTimeStart = latestTimeStart
        }
    }
    
    func advance(userInput: Int? = nil) -> GameState {
        
        if let givenUserInput = userInput {
            assert(currentChallengeIndex >= 0 && currentChallengeIndex < challenges.count,
                "User gave input for a bogus challenge index: \(currentChallengeIndex)")
            let (shouldAdvance, fulfilledChallenge) = challenges[currentChallengeIndex].respond(givenUserInput)
            var mutableChallenges = challenges
            mutableChallenges[currentChallengeIndex] = fulfilledChallenge
            return GameState(
                gameId: gameId,
                n: n,
                challenges: mutableChallenges,
                currentChallengeIndex: shouldAdvance ? currentChallengeIndex + 1 : currentChallengeIndex,
                closedTimeIntervals: closedTimeIntervals,
                latestTimeStart: latestTimeStart,
                peeks: peeks
            )
        } else {
            assert(currentChallengeIndex < 0,
                "User should not be able to advance without giving a response to a valid challenge at index \(currentChallengeIndex)")
            return GameState(
                gameId: gameId,
                n: n,
                challenges: challenges,
                currentChallengeIndex: currentChallengeIndex + 1,
                closedTimeIntervals: closedTimeIntervals,
                latestTimeStart: (currentChallengeIndex + 1 == 0) ? NSDate() : nil,
                peeks: peeks
            )
        }
    }
    
    func addPeek() -> GameState {
        var newPeeks = peeks
        newPeeks.append(NSDate())
        return GameState(
            gameId: gameId,
            n: n,
            challenges: challenges,
            currentChallengeIndex: currentChallengeIndex,
            closedTimeIntervals: closedTimeIntervals,
            latestTimeStart: latestTimeStart,
            peeks: newPeeks
        )
    }
    
    func currentChallenge() -> Challenge? {
        if currentChallengeIndex >= 0 && currentChallengeIndex < challenges.count {
            return challenges[currentChallengeIndex]
        } else {
            return nil
        }
    }
    
    func time(atTime time: NSDate = NSDate()) -> NSTimeInterval {
        return closedTimeIntervals.reduce(0) { $0 + $1.duration() }
             + NSTimeInterval(peeks.count) * penaltyPerPeek
             + time.timeIntervalSinceDate(latestTimeStart ?? time)
    }
    
    func finalTime() -> NSTimeInterval {
        assert(latestTimeStart == nil, "Can't get the final time while the game is still in progress.")
        return time()
    }
    
    func writeTo<Target : OutputStreamType>(inout target: Target) {
        target.write("GAME STATE:\n\tn = \(n)\n\tchallenges = \(challenges)\n\tcurrentChallengeIndex = \(currentChallengeIndex)\n\tclosedTimeIntervals = \(closedTimeIntervals)")
        if let currentTimeIntervalStart = latestTimeStart {
            target.write("\n\tlatestTimeStart = \(latestTimeStart)")
        } else {
            target.write("\n\tfinalTime = \(finalTime())")
        }
    }
}

final class TimeInterval: NSObject, NSCoding {
    let startTime: NSDate
    let endTime: NSDate
    
    init(startTime: NSDate, endTime: NSDate) {
        self.startTime = startTime
        self.endTime = endTime
    }
    
    func duration() -> NSTimeInterval {
        return endTime.timeIntervalSinceDate(startTime)
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(startTime, forKey: "startTime")
        aCoder.encodeObject(endTime, forKey: "endTime")
    }
    
    convenience init(coder aDecoder: NSCoder) {
        self.init(
            startTime: aDecoder.decodeObjectForKey("startTime") as NSDate,
            endTime: aDecoder.decodeObjectForKey("endTime") as NSDate
        )
    }
}

extension GameState: NSCoding {
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(gameId, forKey: "gameId")
        aCoder.encodeInteger(n, forKey: "n")
        aCoder.encodeObject(challenges, forKey: "challenges")
        aCoder.encodeInteger(currentChallengeIndex, forKey: "currentChallengeIndex")
        aCoder.encodeObject(closedTimeIntervals, forKey: "closedTimeIntervals")
        if let currentTimeIntervalStart = latestTimeStart {
            aCoder.encodeObject(currentTimeIntervalStart, forKey: "latestTimeStart")
        }
        aCoder.encodeObject(peeks, forKey: "peeks")
    }
    
    convenience init(coder aDecoder: NSCoder) {
        let newGameId = aDecoder.decodeObjectForKey("gameId") as String
        let newN = aDecoder.decodeIntegerForKey("n")
        let newChallenges = aDecoder.decodeObjectForKey("challenges") as [Challenge]
        let newCurrentChallengeIndex = aDecoder.decodeIntegerForKey("currentChallengeIndex")
        let newClosedTimeIntervals = aDecoder.decodeObjectForKey("closedTimeIntervals") as [TimeInterval]
        let newLatestTimeStart = aDecoder.containsValueForKey("latestTimeStart") ? aDecoder.decodeObjectForKey("latestTimeStart") as NSDate? : nil
        let newPeeks = aDecoder.decodeObjectForKey("peeks") as [NSDate]
        
        self.init(
            gameId: newGameId,
            n: newN,
            challenges: newChallenges,
            currentChallengeIndex: newCurrentChallengeIndex,
            closedTimeIntervals: newClosedTimeIntervals,
            latestTimeStart: newLatestTimeStart,
            peeks: newPeeks
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
