//
//  UIView+ConstraintSanitizing.swift
//  Pickemo
//
//  Created by Vova Galchenko on 4/12/15.
//  Copyright (c) 2015 EVE. All rights reserved.
//

import UIKit

extension UIView {
    class func sanitizeLocationConstraintMultiplier(multiplier: CGFloat) -> CGFloat {
        return (multiplier == 0) ? CGFloat.min : multiplier
    }
}