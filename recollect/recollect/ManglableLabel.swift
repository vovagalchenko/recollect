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
                        attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor): originalTextColor ?? textColor!])
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
    
    
    override var textColor: UIColor! {
        set(newColor) {
            if originalTextColor != nil {
                originalTextColor = newColor
            }
            if let existingOriginalAttributedText = originalAttributedText {
                let attrString = NSMutableAttributedString(attributedString: existingOriginalAttributedText)
                attrString.setAttributes(
                    convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor): newColor]),
                    range: NSRange(location: 0, length: attrString.length)
                )
                originalAttributedText = attrString
            }
            else {
                super.textColor = newColor
            }
        }
        
        get {
            return originalTextColor ?? super.textColor
        }
    }
    private var originalAttributedText: NSAttributedString?
    private var originalTextColor: UIColor?
    
    private let aToZCaps = Array(0x41...0x5A).map { UnicodeScalar($0)! }
    private let aToZLowercase = Array(0x61...0x7A).map { UnicodeScalar($0)! }
    private let zeroToNine = Array(0x30...0x39).map { UnicodeScalar($0)! }
    
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
            mangledString = NSMutableAttributedString(string: originalText!, attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor): originalTextColor!]))
        }
        if mangledString.string.count > 0 {
            let strLength = mangledString.string.count
            let numCharactersToLeaveUnmangled = Int(round(Float(strLength) * portionOfTextToLeaveUnmangled))
            let indexOfSplitChar = mangledString.string.index(mangledString.string.startIndex, offsetBy: numCharactersToLeaveUnmangled)
            var stringToPrepend = ""
            let unicodeScalars = mangledString.string[indexOfSplitChar...].unicodeScalars
            for unicodeScalar in unicodeScalars {
                let replacement: UnicodeScalar
                if aToZCaps.first!.value <= unicodeScalar.value && aToZCaps.last!.value >= unicodeScalar.value {
                    replacement = aToZCaps[Int(arc4random_uniform(UInt32(aToZCaps.count)))]
                } else if aToZLowercase.first!.value <= unicodeScalar.value && aToZLowercase.last!.value >= unicodeScalar.value {
                    replacement = aToZLowercase[Int(arc4random_uniform(UInt32(aToZLowercase.count)))]
                } else if zeroToNine.first!.value <= unicodeScalar.value && zeroToNine.last!.value >= unicodeScalar.value {
                    replacement = zeroToNine[Int(arc4random_uniform(UInt32(zeroToNine.count)))]
                } else {
                    replacement = unicodeScalar
                }
                stringToPrepend.append(Character(replacement))
            }
            let mangledStringRange = NSRange(
                location: mangledString.string.count - stringToPrepend.count,
                length: stringToPrepend.count
            )
            mangledString.mutableString.replaceCharacters(in: mangledStringRange, with: stringToPrepend)
            
            if canUseAlphaForAccents {
                // TODO: ManglableLabel animation probably looks weird if the original attributedText isn't of uniform color, but we don't have that case for now.
                let color = originalTextColor ?? mangledString.attribute(NSAttributedString.Key.foregroundColor, at: 0, effectiveRange: nil) as! UIColor
                var alpha: CGFloat = 0
                color.getRed(nil, green: nil, blue: nil, alpha: &alpha)
                let mangledStringColor = canUseAlphaForAccents ? color.withAlphaComponent(alpha * 0.5) : color
                mangledString.addAttribute(NSAttributedString.Key.foregroundColor, value: mangledStringColor, range: mangledStringRange)
            }
            attributedText = mangledString
        }
    }
    
    func unmangle() {
        if let existingOriginalAttributedText = originalAttributedText {
            attributedText = existingOriginalAttributedText
        } else if let existingOriginalText = originalText {
            super.text = existingOriginalText
            super.attributedText = nil
            textColor = originalTextColor
        }
        originalTextColor = nil
        originalText = nil
        originalAttributedText = nil
        

    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
	guard let input = input else { return nil }
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSAttributedStringKey(_ input: NSAttributedString.Key) -> String {
	return input.rawValue
}
