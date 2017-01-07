//
//  ManglableLabel.swift
//  recollect
//
//  Created by Vova Galchenko on 12/28/14.
//  Copyright (c) 2014 Vova Galchenko. All rights reserved.
//

import UIKit

class ManglableLabel: UILabel {
    
    var originalText: String?
    override var text: String? {
        set(newText) {
            if originalText != nil {
                originalText = newText
            } else if originalAttributedText != nil {
                if let existingNewText = newText {
                    originalAttributedText = NSAttributedString(
                        string: existingNewText,
                        attributes: [NSForegroundColorAttributeName: originalTextColor ?? textColor!]
                    )
                } else {
                    originalAttributedText = nil
                }
            } else {
                super.text = newText
            }
        }
        get {
            if let existingUnmangledText = originalText {
                return existingUnmangledText
            } else if let existingUnmangledAttributedText = originalAttributedText {
                return existingUnmangledAttributedText.string
            } else {
                return super.text
            }
        }
    }
    private var originalAttributedText: NSAttributedString?
    private var originalTextColor: UIColor?
    
    private let aToZCaps = Array(0x41...0x5A).map {UnicodeScalar($0)!}
    private let aToZLowercase = Array(0x61...0x7A).map {UnicodeScalar($0)!}
    private let zeroToNine = Array(0x30...0x39).map {UnicodeScalar($0)!}
    
    init() {
        super.init(frame: CGRect.zero)
        translatesAutoresizingMaskIntoConstraints = false
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) isn't expected to be called because xibs aren't used.")
    }
    
    func mangle(_ portionOfTextToLeaveUnmangled: Float, canUseAlphaForAccents: Bool) {
        if originalText == nil && originalTextColor == nil && originalAttributedText == nil {
            if attributedText != nil {
                originalAttributedText = attributedText
            } else {
                originalText = text
            }
            originalTextColor = textColor
        }
        
        var mangledString: NSMutableAttributedString = NSMutableAttributedString(string: "")
        if let existingOriginalAttributedText = originalAttributedText {
            mangledString = NSMutableAttributedString(attributedString: existingOriginalAttributedText)
        } else if originalText != nil && originalTextColor != nil {
            mangledString = NSMutableAttributedString(string: originalText!, attributes: [NSForegroundColorAttributeName: originalTextColor!])
        }
        if mangledString.string.characters.count > 0 {
            let strLength = mangledString.string.characters.count
            let numCharactersToLeaveUnmangled = Int(round(Float(strLength) * portionOfTextToLeaveUnmangled))
            let indexOfSplitChar = mangledString.string.characters.index(mangledString.string.startIndex, offsetBy: numCharactersToLeaveUnmangled)
            var stringToPrepend = ""
            for character in mangledString.string.substring(from: indexOfSplitChar).unicodeScalars {
                let replacement: UnicodeScalar
                if aToZCaps.first!.value <= character.value && aToZCaps.last!.value >= character.value {
                    replacement = aToZCaps[Int(arc4random_uniform(UInt32(aToZCaps.count)))]
                } else if aToZLowercase.first!.value <= character.value && aToZLowercase.last!.value >= character.value {
                    replacement = aToZLowercase[Int(arc4random_uniform(UInt32(aToZLowercase.count)))]
                } else if zeroToNine.first!.value <= character.value && zeroToNine.last!.value >= character.value {
                    replacement = zeroToNine[Int(arc4random_uniform(UInt32(zeroToNine.count)))]
                } else {
                    replacement = character
                }
                stringToPrepend.append(Character(replacement))
            }
            let mangledStringRange = NSRange(location: mangledString.string.characters.count - stringToPrepend.characters.count, length: stringToPrepend.characters.count)
            mangledString.mutableString.replaceCharacters(in: mangledStringRange, with: stringToPrepend)
            
            if canUseAlphaForAccents {
                // TODO: ManglableLabel animation probably looks weird if the original attributedText isn't of uniform color, but we don't have that case for now.
                let color = originalTextColor ?? mangledString.attribute(NSForegroundColorAttributeName, at: 0, effectiveRange: nil) as! UIColor
                var alpha: CGFloat = 0
                color.getRed(nil, green: nil, blue: nil, alpha: &alpha)
                let mangledStringColor = canUseAlphaForAccents ? color.withAlphaComponent(alpha * 0.5) : color
                mangledString.addAttribute(NSForegroundColorAttributeName, value: mangledStringColor, range: mangledStringRange)
            }
            attributedText = mangledString
        }
    }
    
    func unmangle() {
        if let existingOriginalAttributedText = originalAttributedText {
            attributedText = existingOriginalAttributedText
        } else if let existingOriginalText = originalText {
            super.text = existingOriginalText
            textColor = originalTextColor
        }
        originalTextColor = nil
        originalText = nil
        originalAttributedText = nil
    }
}
