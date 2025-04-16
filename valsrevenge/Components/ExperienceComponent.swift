//
//  ExperienceComponent.swift
//  valsrevenge
//
//  Created by Artem Pereverzev on 03.04.2025.
//  Copyright © 2025 Just Write Code LLC. All rights reserved.
//

import GameplayKit
import SpriteKit

class ExperienceComponent: GKComponent {
    
    @GKInspectable var experienceType: String = GameObjectConfig.defaultExperienceType.rawValue//GameObject.defaultExperienceType
    
    override func didAddToEntity() {
        
    }
    
    func rewardPlayer() {
        guard let scene = componentNode.scene as? GameScene,
              let player = scene.childNode(withName: "player") as? Player,
              let type = GameObjectType(rawValue: experienceType) else {
              //let experience = GameObject.forExperienceType(GameObjectType(rawValue: experienceType)) else {
            return
        }
        let experience = GameObjectConfig.experience(for: type)
        player.addExperience(experience)
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        
    }
    
    override class var supportsSecureCoding: Bool {
        true
    }
    
}
