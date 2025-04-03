//
//  EnemyManager.swift
//  valsrevenge
//
//  Created by Artem Pereverzev on 03.04.2025.
//  Copyright © 2025 Just Write Code LLC. All rights reserved.
//
import GameplayKit
import SpriteKit

class EnemyManager {
    static let shared = EnemyManager()
    private var enemies = [GKEntity]()
    
    func registerEnemy(_ enemy: GKEntity) {
        enemies.append(enemy)
    }
    
    func unregisterEnemy(_ enemy: GKEntity) {
        enemies.removeAll { $0 == enemy }
    }
    
    func pauseAllAttacks() {
//        enemies.forEach { enemy in
//            if let node = enemy.component(ofType: MonsterEntity.self)?.node {
//                node.removeAction(forKey: "repeatEnemyRangeAttack")
//            }
//        }
    }
    
    func resumeAllAttacks() {
        enemies.forEach { enemy in
            if let attackComponent = enemy.component(ofType: AttackComponent.self) {
                attackComponent.startAttack()
            }
        }
    }
}
