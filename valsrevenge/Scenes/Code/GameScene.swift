//
//  GameScene.swift
//  valsrevenge
//
//  Created by Tammy Coron on 7/4/20.
//  Copyright © 2020 Just Write Code LLC. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    var entities = [GKEntity]()
    var graphs = [String : GKGraph]()
    let agentComponentSystem = GKComponentSystem(componentClass: GKAgent2D.self)
    
    let mainGameStateMachine = GKStateMachine(states: [PauseState(), PlayingState()])
    private var lastUpdateTime : TimeInterval = 0
    private var player: Player?
    
    let margin: CGFloat = 20.0
    
    private var leftTouch: UITouch?
    private var rightTouch: UITouch?
    
    lazy var controllerMovement: Controller? = {
        guard let player = player else {
            return nil
        }
        
        let stickImage = SKSpriteNode(imageNamed: "player-val-head_0")
        stickImage.setScale(0.75)
        
        let controller = Controller(stickImage: stickImage,
                                    attachedNode: player,
                                    nodeSpeed: player.movementSpeed,
                                    isMovement: true,
                                    range: 55.0,
                                    color: SKColor(red: 59.0 / 255.0,
                                                   green: 111.0 / 255.0,
                                                   blue: 141.0 / 255.0,
                                                   alpha: 0.75))
        controller.setScale(0.65)
        controller.zPosition += 1
        
        controller.anchorLeft()
        controller.hideLargeArrows()
        controller.hideSmallArrows()
        
        return controller
    }()
    
    lazy var controllerAttack: Controller? = {
        guard let player = player else {
            return nil
        }
        
        let stickImage = SKSpriteNode(imageNamed: "controller_attack")
        stickImage.setScale(0.75)
        
        let controller = Controller(stickImage: stickImage,
                                    attachedNode: player,
                                    nodeSpeed: player.projectileSpeed,
                                    isMovement: false,
                                    range: 55.0,
                                    color: SKColor(red: 160.0 / 255.0,
                                                   green: 65.0 / 255.0,
                                                   blue: 65.0 / 255.0,
                                                   alpha: 0.75))
        controller.setScale(0.65)
        controller.zPosition += 1
        
        controller.anchorRight()
        controller.hideLargeArrows()
        controller.hideSmallArrows()
        
        return controller
    }()
    
    override func sceneDidLoad() {
        self.lastUpdateTime = 0
        
        GameData.shared.saveDataWithFileName("gamedata.json")
    }
    
    override func didMove(to view: SKView) {
        
        mainGameStateMachine.enter(PauseState.self)
        
//        player = childNode(withName: "player") as? Player
//        player?.move(.stop)
        setupPlayer()
        
        setupCamera()
        
        let grassMapNode = childNode(withName: "Grass Tile Map") as? SKTileMapNode
        grassMapNode?.setupEdgeLoop()
        
        let dungeonMapNode = childNode(withName: "Dungeon Tile Map") as? SKTileMapNode
        dungeonMapNode?.setupMapPhysics()
        
        physicsWorld.contactDelegate = self
        
        //startAdvancedNavigation()
        
    }
    
    func setupCamera() {
        guard let player = player else { return }
        let distance = SKRange(constantValue: 0)
        let playerConstraint = SKConstraint.distance(distance, to: player)
        
        camera?.constraints = [playerConstraint]
    }
    
    func setupPlayer() {
        player = childNode(withName: "player") as? Player
        
        if let player = player {
            player.setupHUD(scene: self)
            // player.move(.stop)
            agentComponentSystem.addComponent(player.agent)
        }
        
        if let controllerMovement = controllerMovement {
            addChild(controllerMovement)
        }
        
        if let controllerAttack = controllerAttack {
            addChild(controllerAttack)
        }
        
        setupMusic()
    }
    
    func setupMusic() {
        let musicNode = SKAudioNode(fileNamed: "music")
        musicNode.isPositional = false
        
        // Make the audio node positional
        // so that the music gets louder as
        // the player gets closer to the exit
        if let exit = childNode(withName: "exit") {
            musicNode.position = exit.position
            musicNode.isPositional = true
            listener = player
        }
        
        addChild(musicNode)
    }
    
    func touchDown(atPoint pos : CGPoint, touch: UITouch) {
        mainGameStateMachine.enter(PlayingState.self)
        
        let nodeAtPoint = atPoint(pos)
        
        if let controllerMovement = controllerMovement {
            if controllerMovement.contains(nodeAtPoint) {
                leftTouch = touch
                controllerMovement.beginTracking()
            }
        }
        
        if let controllerAttack = controllerAttack {
            if controllerAttack.contains(nodeAtPoint) {
                rightTouch = touch
                controllerAttack.beginTracking()
            }
        }
        
//        let nodeAtPoint = atPoint(pos)
//        if let touchedNode = nodeAtPoint as? SKSpriteNode {
//            if touchedNode.name?.starts(with: "controller_") == true {
//                let direction = touchedNode.name?.replacingOccurrences(
//                    of: "controller_", with: "")
//                player?.move(Direction(rawValue: direction ?? "stop")!)
//            } else if touchedNode.name == "button_attack" {
//                player?.attack()
//            }
//        }
    }
    
    func touchMoved(toPoint pos: CGPoint, touch: UITouch) {
        
        switch touch {
        case leftTouch:
            if let controllerMovement = controllerMovement {
                controllerMovement.moveJoystick(pos: pos)
            }
        case rightTouch:
            if let controllerAttack = controllerAttack {
                controllerAttack.moveJoystick(pos: pos)
            }
        default:
            break
        }
        
//        let nodeAtPoint = atPoint(pos)
//        if let touchedNode = nodeAtPoint as? SKSpriteNode {
//            if touchedNode.name?.starts(with: "controller_") == true {
//                let direction = touchedNode.name?.replacingOccurrences(
//                    of: "controller_", with: "")
//                player?.move(Direction(rawValue: direction ?? "stop")!)
//            }
//        }
    }
    
    func touchUp(atPoint pos: CGPoint, touch: UITouch) {
        
        switch touch {
        case leftTouch:
            if let controllerMovement = controllerMovement {
                controllerMovement.endTracking()
                leftTouch = touch
            }
        case rightTouch:
            if let controllerAttack = controllerAttack {
                controllerAttack.endTracking()
                rightTouch = touch
            }
        default:
            break
        }
            
//        let nodeAtPoint = atPoint(pos)
//        if let touchedNode = nodeAtPoint as? SKSpriteNode {
//            if touchedNode.name?.starts(with: "controller_") == true {
//                player?.stop()
//            }
//        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchDown(atPoint: t.location(in: self), touch: t) }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self), touch: t) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self), touch: t) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self), touch: t) }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        
        // Initialize _lastUpdateTime if it has not already been
        if (self.lastUpdateTime == 0) {
            self.lastUpdateTime = currentTime
        }
        
        // Calculate time since last update
        let dt = currentTime - self.lastUpdateTime
        
        // Update entities
        for entity in self.entities {
            entity.update(deltaTime: dt)
        }
        
        // Update the components systems
        agentComponentSystem.update(deltaTime: dt)
        
        self.lastUpdateTime = currentTime
    }
    
    override func didFinishUpdate() {
        updateControllerLocation()
        updateHUDLocation()
    }
    
    func updateControllerLocation() {
        
        controllerMovement?.position = CGPoint(x: (viewLeft + margin + insets.left), y: (viewBottom + margin + insets.bottom))
        controllerAttack?.position = CGPoint(x: (viewRight - margin - insets.right), y: (viewBottom + margin + insets.bottom))
        
//        let controller = childNode(withName: "//controller")
//        controller?.position = CGPoint(x: (viewLeft + margin + insets.left),
//                                       y: (viewBottom + margin + insets.bottom))
//        
//        let attackButton = childNode(withName: "//attackButton")
//        attackButton?.position = CGPoint(x: (viewRight - margin - insets.right),
//                                         y: (viewBottom + margin + insets.bottom))
    }
    
    func updateHUDLocation() {
        player?.hud.position = CGPoint(x: (viewRight - margin - insets.right), y: (viewTop - margin - insets.top))
    }
    
//    func startAdvancedNavigation() {
//        
//        // Check for navigation graph and key node
//        guard let sceneGraph = graphs.values.first,
//                let keyNode = childNode(withName: "key") as? SKSpriteNode else {
//            return
//        }
//        
//        // Setup the agent
//        let agent = GKAgent2D()
//        
//        // Setup the delegate and the initial position
//        agent.delegate = keyNode
//        agent.position = vector_float2(Float(keyNode.position.x), Float(keyNode.position.y))
//        
//        // Setup the agent properties
//        agent.mass = 1
//        agent.speed = 50
//        agent.maxSpeed = 100
//        agent.maxAcceleration = 100
//        agent.radius = 60
//        
//        // Find objects
//        var obstacles = [GKCircleObstacle]()
//        
//        // Locate generator nodes
//        enumerateChildNodes(withName: "generator_*") {
//            (node, stop) in
//            
//            // Create compatible obstacle
//            let circle = GKCircleObstacle(radius: Float(node.frame.size.width / 2))
//            circle.position = vector_float2(Float(node.position.x), Float(node.position.y))
//            obstacles.append(circle)
//        }
//        
//        // Find the path
//        if let nodesOnPath = sceneGraph.nodes as? [GKGraphNode2D] {
//            
//            // Show the path (optional code)
//            for (index, node) in nodesOnPath.enumerated() {
//                let shapeNode = SKShapeNode(circleOfRadius: 10)
//                shapeNode.fillColor = .gray
//                shapeNode.position = CGPoint(x: CGFloat(node.position.x), y: CGFloat(node.position.y))
//                
//                // Add node number
//                let number = SKLabelNode(text: "\(index)")
//                number.position.y = 15
//                shapeNode.addChild(number)
//                
//                addChild(shapeNode)
//            }
//            // (end optional code)
//            
//            // Create a path to follow
//            let path = GKPath(graphNodes: nodesOnPath, radius: 0)
//            path.isCyclical = true
//            
//            // Setup the goals
//            let followPath = GKGoal(toFollow: path, maxPredictionTime: 1.0, forward: true)
//            let avoidObstacles = GKGoal(toAvoid: obstacles, maxPredictionTime: 1.0)
//            
//            // Add behavior based on goals
//            agent.behavior = GKBehavior(goals: [followPath, avoidObstacles])
//            
//            // Set goal weights
//            agent.behavior?.setWeight(0.5, for: followPath)
//            agent.behavior?.setWeight(100, for: avoidObstacles)
//            
//            // Add agent to component system
//            agentComponentSystem.addComponent(agent)
//        }
//    }
}
