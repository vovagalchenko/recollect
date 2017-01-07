//
//  Challenge.swift
//  recollect
//
//  Created by Vova Galchenko on 1/3/15.
//  Copyright (c) 2015 Vova Galchenko. All rights reserved.
//

import Foundation

final class Challenge: NSObject, TextOutputStreamable {
    let lOperand: Int
    let rOperand: Int
    let challengeOperator: ChallengeOperator
    var userResponses: [Int] = []
    
    init(left: Int, right: Int) {
        lOperand = left
        rOperand = right
        challengeOperator = .sum
    }
    
    init(left: Int, right: Int, userResponses: [Int]) {
        lOperand = left
        rOperand = right
        self.userResponses = userResponses
        challengeOperator = .sum
    }
    
    init(left: Int, right: Int, challengeOperator: ChallengeOperator, userResponses: [Int]) {
        lOperand = left
        rOperand = right
        self.userResponses = userResponses
        self.challengeOperator = challengeOperator
    }
    
    func respond(_ response: Int) -> (Bool, Challenge) {
        var newResponses = userResponses
        newResponses.append(response)
        return (challengeOperator.apply(lOperand, rOperand: rOperand) == response, Challenge(left: lOperand, right: rOperand, userResponses: newResponses))
    }
    
    func write<Target : TextOutputStream>(to target: inout Target) {
        
        target.write("\(lOperand) \(challengeOperator) \(rOperand)")
        if userResponses.count > 0 {
            target.write(" = \(userResponses)")
        }
    }
}

extension Challenge: NSCoding {
    func encode(with aCoder: NSCoder) {
        aCoder.encode(lOperand, forKey: "lOperand")
        aCoder.encode(rOperand, forKey: "rOperand")
        aCoder.encode(challengeOperator.rawValue, forKey: "challengeOperator")
        aCoder.encode(userResponses, forKey: "userResponses")
    }
    
    convenience init?(coder aDecoder: NSCoder) {
        let newLOperand = aDecoder.decodeInteger(forKey: "lOperand")
        let newROperand = aDecoder.decodeInteger(forKey: "rOperand")
        let newChallengeOperator = ChallengeOperator(rawValue: aDecoder.decodeInteger(forKey: "challengeOperator"))!
        let newUserResponses = aDecoder.decodeObject(forKey: "userResponses") as! [Int]
        
        self.init(
            left: newLOperand,
            right: newROperand,
            challengeOperator: newChallengeOperator,
            userResponses: newUserResponses
        )
    }
}

enum ChallengeOperator: Int, TextOutputStreamable {
    case sum
    
    func apply(_ lOperand: Int, rOperand: Int) -> Int {
        switch (self) {
            case .sum: return (lOperand + rOperand) % 10
        }
    }
    
    func write<Target : TextOutputStream>(to target: inout Target) {
        switch (self) {
            case .sum: target.write("+")
        }
    }
}
