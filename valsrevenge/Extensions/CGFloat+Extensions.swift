//
//  CGFloat+Extensions.swift
//  valsrevenge
//
//  Created by Artem Pereverzev on 30.03.2025.
//  Copyright © 2025 Just Write Code LLC. All rights reserved.
//

import CoreGraphics

extension CGFloat {
    
    func clamped(v1: CGFloat, v2: CGFloat) -> CGFloat {
        let min = v1 < v2 ? v1 : v2
        let max = v1 > v2 ? v1 : v2
        
        return self < min ? min : (self > max ? max : self)
    }
    
    func clamped(to r: ClosedRange<CGFloat>) -> CGFloat {
        let min = r.lowerBound, max = r.upperBound
        return self < min ? min : (self > max ? max : self)
    }
    
}
