//
//  CGVector+Extensions.swift
//  valsrevenge
//
//  Created by Artem Pereverzev on 02.04.2025.
//  Copyright © 2025 Just Write Code LLC. All rights reserved.
//
import SpriteKit

extension CGVector {
    
    func normalized() -> CGVector {
        let length = sqrt(dx * dx + dy * dy)
        
        return length > 0 ? CGVector(dx: dx / length, dy: dy / length) : .zero
    }
    
}
