//
//  DesignLanguage.swift
//  recollect
//
//  Created by Vova Galchenko on 12/24/14.
//  Copyright (c) 2014 Vova Galchenko. All rights reserved.
//

import UIKit

struct DesignLanguage {
    static let TopHalfBGColor = UIColor(red: 48.0/255.0, green: 66.0/255.0, blue: 68.0/255.0, alpha: 1.0)
    static let BottomHalfBGColor = UIColor(red: 26.0/255.0, green: 45.0/255.0, blue: 48.0/255.0, alpha: 1.0)
    static let NeverActiveTextColor = UIColor(red: 131.0/255.0, green: 139.0/255.0, blue: 140.0/255.0, alpha: 1.0)
    static let InactiveTextColor = UIColor(red: 48.0/255.0, green: 66.0/255.0, blue: 68.0/255.0, alpha: 1.0)
    static let ActiveTextColor = UIColor(red: 239.0/255.0, green: 239.0/255.0, blue: 239.0/255.0, alpha: 1.0)
    static let AccentTextColor = UIColor(red: 220.0/255.0, green: 99.0/255.0, blue: 86.0/255.0, alpha: 1.0)
    static let NegativeAccentTextColor = UIColor(red: 220.0/255.0, green: 99.0/255.0, blue: 86.0/255.0, alpha: 1.0)
    static let PositiveAccentTextColor = UIColor(red: 99.0/255.0, green: 220.0/255.0, blue: 86.0/255.0, alpha: 1.0)
    static let ShadowColor = UIColor.black.withAlphaComponent(0.1)
    static let HighlightColor = UIColor.white.withAlphaComponent(0.05)
    
    static let obfuscationBlurRadius: CGFloat = 35
    
    static let ProgressBarHeight: CGFloat = 42.0
    
    static let TransitionAnimationDuration: Foundation.TimeInterval = 1.0
    static let MinorAnimationDuration: Foundation.TimeInterval = 0.35
    
    static func delayBeforeInstructionalOverlay(_ levelId: String, finishedLevelBefore: Bool) -> Foundation.TimeInterval {
        return finishedLevelBefore ? 5.0 : 3.0
    }
}
