// Playground - noun: a place where people can play

func lineInfo(lineWidthInPixels: Float) -> (Float, Float) {
    let scale: Float = 1.0
    let widthInPts = lineWidthInPixels/scale
    let offset = widthInPts/2
    return (widthInPts, offset)
}

lineInfo(1.0)
lineInfo(2.0)

func banana(dotsSpread: Float, i: Int) -> Float {
    return -(dotsSpread/2.0) + ((dotsSpread*Float(i))/Float(10 - 1))
}

banana(50, 0)


let arr = [1, 2, 3, 4, 5]
var mutableArr = arr
var anotherArr = [1, 2, 3, 4]

class Test {
    var dict: [String: Int] {
        didSet {
            println("HERRO: \(dict)")
            woah = dict
        }
    }
    
    var woah: [String: Int]
    
    init() {
        dict = [String: Int]()
        woah = dict
    }
}

class Something {
    var t: Int? =  -1
}

let s = Something()
if s.t < 0 {
    println("hello")
}

s.t < 0

let h = [0, 1, 2, 3, 4, 5, 6]
h[0..<2]