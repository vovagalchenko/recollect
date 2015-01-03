//
//  Challenge.swift
//  recollect
//
//  Created by Vova Galchenko on 1/3/15.
//  Copyright (c) 2015 Vova Galchenko. All rights reserved.
//

import Foundation

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