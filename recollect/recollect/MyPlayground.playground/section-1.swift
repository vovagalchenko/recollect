import Foundation

let total = 100
let start = 0
let startTime = NSTimeInterval(start)
let totalLength = NSTimeInterval(total)
for elapsed in start...total {
    let elapsedTime = NSTimeInterval(elapsed)
    let portionElapsed = Float(elapsedTime/totalLength)
    var value: Float
    // Simple quadratic ease-in/ease-out.
    if portionElapsed < 0.5 {
        // We are accelerating
        value = portionElapsed * portionElapsed * 2.0
    } else {
        // We are decelerating
        value = 1.0 - 2.0*pow(portionElapsed - 1.0, 2)
    }
    value
}


let t = -11 % 10

(0...4).endIndex
for i in (0...4) {
    print(i)
}

enum GameplayInput: Int {
    case Zero, One, Two, Three, Four, Five, Six, Seven, Eight, Nine, Back, Forward
    
    static func fromString(str: String) -> GameplayInput {
        switch(str) {
        case "0", "1", "2", "3", "4", "5", "6", "7", "8", "9": return GameplayInput(rawValue: str.toInt()!)!
        case "«": return GameplayInput.Back
        case "»": return GameplayInput.Forward
        default: fatalError("Unexpected string to create a GameplayInput from: \(str)")
        }
    }
}

println("\(GameplayInput.Back)")