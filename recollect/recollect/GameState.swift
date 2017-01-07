//
//  GameState.swift
//  recollect
//
//  Created by Vova Galchenko on 1/3/15.
//  Copyright (c) 2015 Vova Galchenko. All rights reserved.
//

import Foundation

final class GameState: NSObject, TextOutputStreamable {
    let gameId: String
    let n: Int
    var levelId: String {
        return "\(n)"
    }
    let challenges: [Challenge]
    let currentChallengeIndex: Int
    let closedTimeIntervals: [TimeInterval]
    let latestTimeStart: Date?
    let peeks: [Date]
    
    init(n: Int, numRounds: Int) {
        gameId = UUID().uuidString
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
        latestTimeStart = nil
    }
    
    init(gameId: String, n: Int, challenges: [Challenge], currentChallengeIndex: Int, closedTimeIntervals: [TimeInterval], latestTimeStart: Date?, peeks: [Date]) {
        self.gameId = gameId
        self.n = n
        self.challenges = challenges
        self.currentChallengeIndex = currentChallengeIndex
        self.peeks = peeks
        
        if currentChallengeIndex >= self.challenges.count && latestTimeStart != nil {
            self.closedTimeIntervals = closedTimeIntervals + [TimeInterval(startTime: latestTimeStart!, endTime: Date())]
            self.latestTimeStart = nil
        } else {
            self.closedTimeIntervals = closedTimeIntervals
            self.latestTimeStart = latestTimeStart
        }
    }
    
    func advance(_ userInput: Int? = nil) -> GameState {
        
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
                latestTimeStart: (currentChallengeIndex + 1 == 0) ? Date() : nil,
                peeks: peeks
            )
        }
    }
    
    func addPeek() -> GameState {
        var newPeeks = peeks
        newPeeks.append(Date())
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
    
    func time(atTime time: Date = Date()) -> Foundation.TimeInterval {
        return closedTimeIntervals.reduce(0) { $0 + $1.duration() }
             + Foundation.TimeInterval(peeks.count) * GameManager.penaltyPerPeek
             + time.timeIntervalSince(latestTimeStart ?? time)
    }
    
    func finalTime() -> Foundation.TimeInterval {
        assert(isFinished(), "Can't get the final time while the game is still in progress.")
        return time()
    }
    
    func isFlawless() -> Bool { return challenges.reduce(peeks.count == 0) { $0 && $1.userResponses.count <= 1 } }
    func isFinished() -> Bool { return currentChallengeIndex >= challenges.count && latestTimeStart == nil }
    
    func write<Target : TextOutputStream>(to target: inout Target) {
        target.write("GAME STATE:\n\tn = \(n)\n\tchallenges = \(challenges)\n\tcurrentChallengeIndex = \(currentChallengeIndex)\n\tclosedTimeIntervals = \(closedTimeIntervals)")
        if let currentTimeIntervalStart = latestTimeStart {
            target.write("\n\tlatestTimeStart = \(currentTimeIntervalStart)")
        } else {
            target.write("\n\tfinalTime = \(finalTime())")
        }
    }
}

final class TimeInterval: NSObject, NSCoding {
    let startTime: Date
    let endTime: Date
    
    init(startTime: Date, endTime: Date) {
        self.startTime = startTime
        self.endTime = endTime
    }
    
    func duration() -> Foundation.TimeInterval {
        return endTime.timeIntervalSince(startTime)
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(startTime, forKey: "startTime")
        aCoder.encode(endTime, forKey: "endTime")
    }
    
    convenience init?(coder aDecoder: NSCoder) {
        self.init(
            startTime: aDecoder.decodeObject(forKey: "startTime") as! Date,
            endTime: aDecoder.decodeObject(forKey: "endTime") as! Date
        )
    }
}

extension GameState: NSCoding {
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(gameId, forKey: "gameId")
        aCoder.encode(n, forKey: "n")
        aCoder.encode(challenges, forKey: "challenges")
        aCoder.encode(currentChallengeIndex, forKey: "currentChallengeIndex")
        aCoder.encode(closedTimeIntervals, forKey: "closedTimeIntervals")
        if let currentTimeIntervalStart = latestTimeStart {
            aCoder.encode(currentTimeIntervalStart, forKey: "latestTimeStart")
        }
        aCoder.encode(peeks, forKey: "peeks")
    }
    
    convenience init?(coder aDecoder: NSCoder) {
        let newGameId = aDecoder.decodeObject(forKey: "gameId") as! String
        let newN = aDecoder.decodeInteger(forKey: "n")
        let newChallenges = aDecoder.decodeObject(forKey: "challenges") as! [Challenge]
        let newCurrentChallengeIndex = aDecoder.decodeInteger(forKey: "currentChallengeIndex")
        let newClosedTimeIntervals = aDecoder.decodeObject(forKey: "closedTimeIntervals") as! [TimeInterval]
        let newLatestTimeStart = aDecoder.containsValue(forKey: "latestTimeStart") ? aDecoder.decodeObject(forKey: "latestTimeStart") as! Date? : nil
        let newPeeks = aDecoder.decodeObject(forKey: "peeks") as! [Date]
        
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

class GameStateChange {
    let oldGameState: GameState?
    let newGameState: GameState?
    
    init(oldGameState: GameState? = nil, newGameState: GameState? = nil) {
        self.oldGameState = oldGameState
        self.newGameState = newGameState
    }
}
