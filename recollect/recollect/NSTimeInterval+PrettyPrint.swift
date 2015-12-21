//
//  NSTimeInterval+PrettyPrint.swift
//  recollect
//
//  Created by Vova Galchenko on 1/6/15.
//  Copyright (c) 2015 Vova Galchenko. All rights reserved.
//

import Foundation

extension NSTimeInterval {
    func minuteSecondCentisecondString(signed: Bool = false) -> String {
        let absoluteValue = abs(self)
        let mins = Int(floor(absoluteValue/60.0))
        let secs = Int(floor(absoluteValue - NSTimeInterval(mins*60)))
        let centiseconds = Int(floor((absoluteValue - floor(absoluteValue))*100))
        var result = NSString(format: "%02d:%02d.%02d", mins, secs, centiseconds) as String
        if self < 0 {
            result = "- " + result
        } else if signed {
            result = "+ " + result
        }
        return result
    }
}