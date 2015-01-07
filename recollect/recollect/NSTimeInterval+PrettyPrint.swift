//
//  NSTimeInterval+PrettyPrint.swift
//  recollect
//
//  Created by Vova Galchenko on 1/6/15.
//  Copyright (c) 2015 Vova Galchenko. All rights reserved.
//

import Foundation

extension NSTimeInterval {
    func minuteSecondCentisecondString() -> NSString {
        let mins = Int(floor(self/60.0))
        let secs = Int(floor(self - NSTimeInterval(mins*60)))
        let centiseconds = Int(floor((self - floor(self))*100))
        var result = NSString(format: "%02d:%02d:%02d", abs(mins), secs, centiseconds)
        if mins < 0 {
            result = "- " + result
        }
        return result
    }
}