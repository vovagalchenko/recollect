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