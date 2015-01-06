//
//  ManglableLabel.swift
//  recollect
//
//  Created by Vova Galchenko on 12/28/14.
//  Copyright (c) 2014 Vova Galchenko. All rights reserved.
//

import UIKit

class ManglableLabel: UILabel {
    
    private var originalText: String?
    private var originalTextColor: UIColor?
    
    let aToZCaps = Array(0x41...0x5A).map {UnicodeScalar($0)}
    let aToZLowercase = Array(0x61...0x7A).map {UnicodeScalar($0)}
    let zeroToNine = Array(0x30...0x39).map {UnicodeScalar($0)}
    
    func mangle(portionOfTextToLeaveUnmangled: Float, canUseAlphaForAccents: Bool) {
        
        assert(self.numberOfLines == 1, "Mangling of a multiline label doesn't work exactly as expected!")
        
        if originalText == nil || originalTextColor == nil {
            originalText = text
            originalTextColor = textColor
        }
        
        if let existingOriginalText = originalText {
            let strLength = countElements(existingOriginalText)
            let numCharactersToLeaveUnmangled = Int(round(Float(strLength) * portionOfTextToLeaveUnmangled))
            let indexOfSplitChar = advance(existingOriginalText.startIndex, numCharactersToLeaveUnmangled)
            var newString = NSMutableAttributedString(string: existingOriginalText.substringToIndex(indexOfSplitChar), attributes: [NSForegroundColorAttributeName: originalTextColor!])
            var alpha: CGFloat = 0
            originalTextColor?.getRed(nil, green: nil, blue: nil, alpha: &alpha)
            let mangledStringColor = canUseAlphaForAccents ? originalTextColor!.colorWithAlphaComponent(alpha * 0.5) : originalTextColor!
            for character in existingOriginalText.substringFromIndex(indexOfSplitChar).unicodeScalars {
                var replacement = character
                if aToZCaps[0] <= character && aToZCaps[aToZCaps.count - 1] >= character {
                    replacement = aToZCaps[Int(arc4random_uniform(UInt32(aToZCaps.count)))]
                } else if aToZLowercase[0] <= character && aToZLowercase[aToZLowercase.count - 1] >= character {
                    replacement = aToZLowercase[Int(arc4random_uniform(UInt32(aToZLowercase.count)))]
                } else if zeroToNine[0] <= character && zeroToNine[zeroToNine.count - 1] >= character {
                    replacement = zeroToNine[Int(arc4random_uniform(UInt32(zeroToNine.count)))]
                }
                newString.appendAttributedString(NSAttributedString(string: String(replacement), attributes: [NSForegroundColorAttributeName: mangledStringColor]))
            }
            attributedText = newString
        }
    }
    
    func unmangle() {
        if let existingOriginalText = originalText {
            text = existingOriginalText
            textColor = originalTextColor
        }
    }
}