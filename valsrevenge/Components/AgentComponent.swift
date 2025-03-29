//
//  AgentComponent.swift
//  valsrevenge
//
//  Created by Artem Pereverzev on 26.03.2025.
//  Copyright © 2025 Just Write Code LLC. All rights reserved.
//
import SpriteKit
import GameplayKit

class AgentComponent: GKComponent {
    
    let agent = GKAgent2D()
    
    lazy var interceptGoal: GKGoal = {
        guard let scene = componentNode.scene as? GameScene,
              let player = scene.childNode(withName: "player") as? Player else {
            return GKGoal(toWander: 1.0)
        }
        
        return GKGoal(toInterceptAgent: player.agent, maxPredictionTime: 1.0)
    }()
    
    override func didAddToEntity() {
        
        guard let scene = componentNode.scene as? GameScene else {
            return
        }
        
        // Setup the goals and behaviors
        let wanderGoal = GKGoal(toWander: 1.0)
        agent.behavior = GKBehavior(goals: [wanderGoal, interceptGoal], andWeights: [100, 0])
        
        // Set the delegate
        agent.delegate = componentNode
        
        // Constrain the agent's movement
        agent.mass = 1
        agent.maxAcceleration = 125
        agent.maxSpeed = 125
        agent.radius = 60
        agent.speed = 100
        
        // Add the agent component to the component system
        scene.agentComponentSystem.addComponent(agent)
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        guard let scene = componentNode.scene as? GameScene,
              let player = scene.childNode(withName: "player") as? Player else {
            return
        }
        
        switch player.stateMachine.currentState {
        case is PlayerHasKeyState:
            agent.behavior?.setWeight(100, for: interceptGoal)
        default:
            agent.behavior?.setWeight(0, for: interceptGoal)
        }
    }
    
    override class var supportsSecureCoding: Bool {
        true
    }
    
}
