//
//  MonsterEntity.swift
//  valsrevenge
//
//  Created by Artem Pereverzev on 23.03.2025.
//  Copyright © 2025 Just Write Code LLC. All rights reserved.
//
import SpriteKit
import GameplayKit

class MonsterEntity: GKEntity {
    
    init(monsterType: String) {
        super.init()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
}
