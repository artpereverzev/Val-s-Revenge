//
//  PathfindingComponent.swift
//  valsrevenge
//
//  Created by Artem Pereverzev on 26.03.2025.
//  Copyright © 2025 Just Write Code LLC. All rights reserved.
//
import SpriteKit
import GameplayKit

class PathfindingComponent: GKComponent {
    
    @GKInspectable var idPath: Int = 0
    
    let agent = GKAgent2D()
    var isRunning = false
    
    func startPathfinding() {
        guard let scene = componentNode.scene as? GameScene,
              let sceneGraph = scene.graphs.values.first else {
            return
        }
        
        // START: TO FIX (AND TO DELETE)
        print("SCENEGRAPH: \(sceneGraph)")
        
        let sceneGraphs = scene.graphs
        var arrayGraphs = [GKGraph]()
        
        for sc in sceneGraphs {
            print("Graph sceneName: \(sc.key)\nGraph sceneValue: \(sc.value)")
            arrayGraphs.append(sc.value)
        }
        print("All graphs: \(arrayGraphs)\nAll graph nodes: \(String(describing: sceneGraph.nodes))\nNODES: \(arrayGraphs[0].nodes)")
        // END: TO FIX (AND TO DELETE)
        
        // Start pathfinding
        isRunning = true
        
        // Set up the delegate and the initial position
        agent.delegate = componentNode
        agent.position = vector_float2(Float(componentNode.position.x),
                                       Float(componentNode.position.y))
        
        // Set up the agent's properties
        agent.mass = 1
        agent.speed = 50
        agent.maxSpeed = 100
        agent.maxAcceleration = 100
        agent.radius = 60
        
        // Find obstacles (generators)
        var obstacles = [GKCircleObstacle]()
        
        // Locate generator nodes
        scene.enumerateChildNodes(withName: "generator_*") {
            (node, stop) in
            
            // Create compatible obstacle
            let circle = GKCircleObstacle(radius: Float(node.frame.size.width/2))
            circle.position = vector_float2(Float(node.position.x),
                                            Float(node.position.y))
            obstacles.append(circle)
        }
        
        // Find the path
        if let nodesOnPath = sceneGraph.nodes as? [GKGraphNode2D] {
            print("SCENEGRAPH.NODE: \(nodesOnPath)")// TO DELETE
            
            // Show the path (optional code)
            for (index, node) in nodesOnPath.enumerated() {
                let shapeNode = SKShapeNode(circleOfRadius: 10)
                shapeNode.fillColor = .green
                shapeNode.position = CGPoint(x: CGFloat(node.position.x),
                                             y: CGFloat(node.position.y))
                
                // Add node number
                let number = SKLabelNode(text: "\(index)")
                number.position.y = 15
                shapeNode.addChild(number)
                
                scene.addChild(shapeNode)
            }
            // (end optional code)
            
            
            // Create a path to follow
            let path = GKPath(graphNodes: nodesOnPath, radius: 0)
            path.isCyclical = true
            
            // Set up the goals
            let followPath = GKGoal(toFollow: path, maxPredictionTime: 1.0,
                                    forward: true)
            let avoidObstacles = GKGoal(toAvoid: obstacles, maxPredictionTime: 1.0)
            
            // Add behavior based on goals
            agent.behavior = GKBehavior(goals: [followPath, avoidObstacles])
            
            // Set goal weights
            agent.behavior?.setWeight(0.5, for: followPath)
            agent.behavior?.setWeight(100, for: avoidObstacles)
            
            // Add agent to component system
            scene.agentComponentSystem.addComponent(agent)
        }
    }
    
    func stopPathfinding() {
        isRunning = false     // stop pathfinding and
        agent.delegate = nil  // remove the delegate to
        // stop the positional updates
    }
    
    // Use the update method to start and stop pathfinding
    override func update(deltaTime seconds: TimeInterval) {
        if let scene = componentNode.scene as? GameScene {
            switch scene.mainGameStateMachine.currentState {
            case is PauseState:
                if isRunning == true {
                    stopPathfinding()
                }
            case is PlayingState:
                if isRunning == false {
                    startPathfinding()
                }
            default:
                break
            }
        }
    }
    
    override class var supportsSecureCoding: Bool {
        true
    }
}
