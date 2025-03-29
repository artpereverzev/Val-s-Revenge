//
//  HealthComponent.swift
//  valsrevenge
//
//  Created by Artem Pereverzev on 23.03.2025.
//  Copyright © 2025 Just Write Code LLC. All rights reserved.
//

import SpriteKit
import GameplayKit

class HealthComponent: GKComponent {
    
    @GKInspectable var currentHealth: Int = 3
    @GKInspectable var maxHealth: Int = 3
    
    private let healthFull = SKTexture(imageNamed: "health_full")
    private let healthEmpty = SKTexture(imageNamed: "health_empty")
    
    private var hitAction = SKAction()
    private var dieAction = SKAction()
    
    override func didAddToEntity() {
        
        if let healthMeter = SKReferenceNode(fileNamed: "HealthMeter") {
            healthMeter.position = CGPoint(x: 0, y: 100)
            componentNode.addChild(healthMeter)
            
            updateHealth(0, forNode: componentNode)
            
            if let _ = componentNode as? Player {
                hitAction = SKAction.playSoundFileNamed("player_hit", waitForCompletion: false)
                
                let playSound = SKAction.playSoundFileNamed("player_die", waitForCompletion: false)
                dieAction = SKAction.run {
                    self.componentNode.run(playSound, completion: {
                        // TODO: Add code to restart the game
                        // but for now, reset the player's health
                        self.currentHealth = self.maxHealth
                    })
                }
            } else {
                hitAction = SKAction.playSoundFileNamed("monster_hit", waitForCompletion: false)
                let playSound = SKAction.playSoundFileNamed("monster_die", waitForCompletion: false)
                
                dieAction = SKAction.run {
                    self.componentNode.run(playSound, completion: {
                        self.componentNode.removeFromParent()
                    })
                }
            }
        }
        
    }
    
    func updateHealth(_ value: Int, forNode node: SKNode?) {
        currentHealth += value
        
        if currentHealth >= maxHealth {
            currentHealth = maxHealth
        }
        
        // Run hit or die action
        if value < 0 {
            if currentHealth == 0 {
                componentNode.run(dieAction)
            } else {
                componentNode.run(hitAction)
            }
        }
        
        if let _ = node as? Player {
            for barNum in 1...maxHealth {
                setupBar(at: barNum, tint: .cyan)
            }
        } else {
            for barNum in 1...maxHealth {
                setupBar(at: barNum)
            }
        }
    }
    
    func setupBar(at num: Int, tint: SKColor? = nil) {
        
        if let health = componentNode.childNode(withName: ".//health_\(num)") as? SKSpriteNode{
            if currentHealth >= num {
                health.texture = healthFull
                if let tint = tint {
                    health.color = tint
                    health.colorBlendFactor = 1.0
                }
            } else {
                health.texture = healthEmpty
                health.colorBlendFactor = 0.0
            }
        }
        
    }
    
    override func willRemoveFromEntity() {
        
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        
    }
    
    override class var supportsSecureCoding: Bool {
        true
    }
}
