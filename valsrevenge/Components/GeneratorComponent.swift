//
//  GeneratorComponent.swift
//  valsrevenge
//
//  Created by Artem Pereverzev on 23.03.2025.
//  Copyright © 2025 Just Write Code LLC. All rights reserved.
//

import SpriteKit
import GameplayKit

class GeneratorComponent: GKComponent {
    
    @GKInspectable var monsterType: String = GameObject.defaultGeneratorType
    @GKInspectable var maxMonsters: Int = 10
    
    @GKInspectable var waitTime: TimeInterval = 5
    @GKInspectable var monsterHealth: Int = 3
    
    var isRunning = false
    
    func startGenerator() {
        isRunning = true
        
        let wait = SKAction.wait(forDuration: waitTime)
        let spawn = SKAction.run { [unowned self] in self.spawnMonsterEntity() }
        let sequence = SKAction.sequence([wait, spawn])
        
        let repeatAction: SKAction?
        if maxMonsters == 0 {
            repeatAction = SKAction.repeatForever(sequence)
        } else {
            repeatAction = SKAction.repeat(sequence, count: maxMonsters)
        }
        
        componentNode.run(repeatAction!, withKey: "spawnMonsters")
        
    }
    
    func stopGenerator() {
        isRunning = false
        componentNode.removeAction(forKey: "spawnMonsters")
    }
    
    func spawnMonsterEntity() {
        let monsterEntity = MonsterEntity(monsterType: monsterType)
        let renderComponent = RenderComponent(imageNamed: "\(monsterType)_0", scale: 0.65)
        monsterEntity.addComponent(renderComponent)
        
        if let monsterNode = monsterEntity.component(ofType: RenderComponent.self)?.spriteNode {
            monsterNode.position = componentNode.position
            componentNode.parent?.addChild(monsterNode)
            
            //monsterNode.run(SKAction.moveBy(x: 100, y: 0, duration: 1.0))
            // Initial spawn movement
            let randomPosition: [CGFloat] = [-50, -50, 50]
            let randomX = randomPosition.randomElement() ?? 0
            monsterNode.run(SKAction.moveBy(x: randomX, y: 0, duration: 1.0))
            
            let healthComponent = HealthComponent()
            healthComponent.currentHealth = monsterHealth
            monsterEntity.addComponent(healthComponent)
            
            let agentComponent = AgentComponent()
            monsterEntity.addComponent(agentComponent)
            
            let physicsComponent = PhysicsComponent()
            physicsComponent.bodyCategory = PhysicsCategory.monster.rawValue
            monsterEntity.addComponent(physicsComponent)
            
            if let scene = componentNode.scene as? GameScene {
                scene.entities.append(monsterEntity)
            }
            
        }
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        if let scene = componentNode.scene as? GameScene {
            switch scene.mainGameStateMachine.currentState {
            case is PauseState:
                if isRunning == true {
                    stopGenerator()
                    print("Generator: STOP")
                }
            case is PlayingState:
                if isRunning == false {
                    startGenerator()
                    print("Generator: START")
                }
            default:
                break
            }
        }
    }
    
    override func didAddToEntity() {
        
        let physicsComponent = PhysicsComponent()
        physicsComponent.bodyCategory = PhysicsCategory.monster.rawValue
        componentNode.entity?.addComponent(physicsComponent)
        
    }
    
    override class var supportsSecureCoding: Bool {
        true
    }
}
