//
//  Player.swift
//  valsrevenge
//
//  Created by Tammy Coron on 7/4/20.
//  Copyright © 2020 Just Write Code LLC. All rights reserved.
//

import SpriteKit
import GameplayKit

//enum Direction: String {
//    case stop
//    case left
//    case right
//    case up
//    case down
//    case topLeft
//    case topRight
//    case bottomLeft
//    case bottomRight
//}

class Player: SKSpriteNode {
    
    // Player properties
    var stateMachine = GKStateMachine(states: [PlayerHasKeyState(), PlayerHasNoKeyState()])
    
    var movementSpeed: CGFloat = 5
    
    var level = String(GameData.shared.level)
    
    var maxProjectiles: Int = 1
    var numProjectiles: Int = 0
    
    var projectileSpeed: CGFloat = 25
    var projectileRange: TimeInterval = 1
    
    let attackDelay = SKAction.wait(forDuration: 0.25)
    
    var hud = SKNode()
    private let treasureLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
    private let keysLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
    private let levelLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
    
    private var keys: Int = GameData.shared.keys {
        didSet {
            keysLabel.text = "Keys: \(keys)"
            print("Keys: \(keys)")
            if keys < 1 {
                print("stateMachine: PlayerHasNoKeyState")
                stateMachine.enter(PlayerHasNoKeyState.self)
            } else {
                print("stateMachine: PlayerHasKeyState")
                stateMachine.enter(PlayerHasKeyState.self)
            }
        }
    }
    
    private var treasure: Int = GameData.shared.treasure {
        didSet {
            treasureLabel.text = "Treasure: \(treasure)"
            print("Treasure: \(treasure)")
        }
    }
    
    var agent = GKAgent2D()
    //private var currentDirection = Direction.stop
    
    func getStats() -> (keys: Int, treasure: Int) {
        return (self.keys, self.treasure)
    }
    
    // Override this method to allow for a class to work in Scene Editor
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        stateMachine.enter(PlayerHasNoKeyState.self)
        
        agent.delegate = self
    }
    
    func setupHUD(scene: GameScene) {
        
        // Setup the treasure label
        treasureLabel.text = "Treasure: \(treasure)"
        treasureLabel.horizontalAlignmentMode = .right
        treasureLabel.verticalAlignmentMode = .center
        treasureLabel.position = CGPoint(x: 0, y: -treasureLabel.frame.height)
        treasureLabel.zPosition += 1
        
        // Setup the keys label
        keysLabel.text = "Keys: \(keys)"
        keysLabel.horizontalAlignmentMode = .right
        keysLabel.verticalAlignmentMode = .center
        keysLabel.position = CGPoint(x: 0, y: treasureLabel.frame.minY - keysLabel.frame.height)
        keysLabel.zPosition += 1
        
        // Setup the level label
        levelLabel.text = "Level: \(level)"
        levelLabel.horizontalAlignmentMode = .right
        levelLabel.verticalAlignmentMode = .center
        levelLabel.position = CGPoint(x: 0, y: treasureLabel.frame.minY - (keysLabel.frame.height * 2.1))
        levelLabel.zPosition += 1
        
        // Add labels to the HUD
        hud.addChild(treasureLabel)
        hud.addChild(keysLabel)
        hud.addChild(levelLabel)
        
        // Add the HUD to the scene
        scene.addChild(hud)
    }
    
    func collectItem(_ collectibleNode: SKNode) {
        guard let collectible = collectibleNode.entity?.component(ofType: CollectibleComponent.self) else {
            return
        }
        
        collectible.collectedItem()
        
        switch GameObjectType(rawValue: collectible.collectibleType) {
        case .key:
            print("Collected key")
            keys += collectible.value
            print("Keys total: \(keys)")
            
        case .food:
            print("Collected food")
            if let hc = entity?.component(ofType: HealthComponent.self) {
                hc.updateHealth(collectible.value, forNode: self)
            }
            
        case .treasure:
            print("Collected treasure")
            treasure += collectible.value
            
        default:
            break
        }
    }
    
    func useKeyToOpenDoor(_ doorNode: SKNode) {
        print("Use key to open door")
        
        switch stateMachine.currentState {
        case is PlayerHasKeyState:
            keys -= 1
            print("Keys total: \(keys)")
            
            doorNode.removeFromParent()
            run(SKAction.playSoundFileNamed("door_open", waitForCompletion: true))
            
        default:
            break
        }
    }
    
    func attack(direction: CGVector, emitterNamed: String?) {
        
        // Verify the direction isn't zero and that the player hasn't
        // shot more projectiles than the max allowed at one time
        if direction != .zero && numProjectiles < maxProjectiles {
            
            // Increase the number of "current" projectiles
            numProjectiles += 1
            
            // Setup the projectile
            let projectile = SKSpriteNode(imageNamed: "knife")
            projectile.position = CGPoint(x: 0.0, y: 0.0)
            projectile.zPosition += 1
            
            // TODO: Need to decide moving to other component? Or create entire attack component with particles, attack type (range/melee etc)?
            // Setup optional particles for projectile
            if let emitterNamed = emitterNamed,
               let particles = SKEmitterNode(fileNamed: emitterNamed) {
                particles.name = "particles"
                particles.position = CGPoint(x: 0.0, y: -20.0)
                projectile.addChild(particles)
            }
            
            addChild(projectile)
            
            // Setup the physics for the projectile
            let physicsBody = SKPhysicsBody(rectangleOf: projectile.size)
            
            physicsBody.affectedByGravity = false
            physicsBody.allowsRotation = true
            physicsBody.isDynamic = true
    
            physicsBody.categoryBitMask = PhysicsBody.projectile.categoryBitMask
            physicsBody.contactTestBitMask = PhysicsBody.projectile.contactTestBitMask
            physicsBody.collisionBitMask = PhysicsBody.projectile.collisionBitMask
            
            projectile.physicsBody = physicsBody
            
            // Set the throw direction
            let throwDirection = CGVector(dx: direction.dx * projectileSpeed,
                                          dy: direction.dy * projectileSpeed)
            
            // Create and run the actions to attack
            let wait = SKAction.wait(forDuration: projectileRange)
            let removeFromScene = SKAction.removeFromParent()
            
            let spin = SKAction.applyTorque(0.25, duration: projectileRange)
            let toss = SKAction.move(by: throwDirection, duration: projectileRange)
            
            let actionTTL = SKAction.sequence([wait, removeFromScene])
            let actionThrow = SKAction.group([spin, toss])
            
            let actionAttack = SKAction.group([actionTTL, actionThrow])
            projectile.run(actionAttack)
            
            // Setup attack govenor (attack speed limiter)
            let reduceCount = SKAction.run({
                self.numProjectiles -= 1
            })
            let reduceSequence = SKAction.sequence([attackDelay, reduceCount])
            run(reduceSequence)
        }
    }
    
//    func move(_ direction: Direction) {
//        //print("move player: \(direction.rawValue)")
//        switch direction {
//        case .up:
//            self.physicsBody?.velocity = CGVector(dx: 0, dy: 100)
//            //self.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 100))
//            //self.physicsBody?.applyForce(CGVector(dx: 0, dy: 100))
//        case .down:
//            self.physicsBody?.velocity = CGVector(dx: 0, dy: -100)
//        case .left:
//            self.physicsBody?.velocity = CGVector(dx: -100, dy: 0)
//        case .right:
//            self.physicsBody?.velocity = CGVector(dx: 100, dy: 0)
//        case .topLeft:
//            self.physicsBody?.velocity = CGVector(dx: -100, dy: 100)
//        case .topRight:
//            self.physicsBody?.velocity = CGVector(dx: 100, dy: 100)
//        case .bottomLeft:
//            self.physicsBody?.velocity = CGVector(dx: -100, dy: -100)
//        case .bottomRight:
//            self.physicsBody?.velocity = CGVector(dx: 100, dy: -100)
//        case .stop:
//            stop()
//        }
//        
//        if direction != .stop {
//            currentDirection = direction
//        }
//    }
    
//    func stop() {
//        self.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
//    }
    
//    func attack() {
//        let projectile = SKSpriteNode(imageNamed: "knife")
//        projectile.position = CGPoint(x: 0.0, y: 0.0)
//        addChild(projectile)
//        
//        // Setup physics for projectile
//        let physicsBody = SKPhysicsBody(rectangleOf: projectile.size)
//        
//        physicsBody.affectedByGravity = false
//        physicsBody.allowsRotation = true
//        physicsBody.isDynamic = true
//        
//        physicsBody.categoryBitMask = PhysicsBody.projectile.categoryBitMask
//        physicsBody.contactTestBitMask = PhysicsBody.projectile.contactTestBitMask
//        physicsBody.collisionBitMask = PhysicsBody.projectile.collisionBitMask
//        
//        projectile.physicsBody = physicsBody
//        
//        var throwDirection = CGVector(dx: 0, dy: 0)
//        
//        switch currentDirection {
//        case .up:
//            throwDirection = CGVector(dx: 0, dy: 300)
//            projectile.zRotation = 0
//        case .down:
//            throwDirection = CGVector(dx: 0, dy: -300)
//            projectile.zRotation = -CGFloat.pi
//        case .left:
//            throwDirection = CGVector(dx: -300, dy: 0)
//            projectile.zRotation = CGFloat.pi/2
//        case .right, .stop: // default pre-movement (throw right)
//            throwDirection = CGVector(dx: 300, dy: 0)
//            projectile.zRotation = -CGFloat.pi/2
//        case .topLeft:
//            throwDirection = CGVector(dx: -300, dy: 300)
//            projectile.zRotation = CGFloat.pi/4
//        case .topRight:
//            throwDirection = CGVector(dx: 300, dy: 300)
//            projectile.zRotation = -CGFloat.pi/4
//        case .bottomLeft:
//            throwDirection = CGVector(dx: -300, dy: -300)
//            projectile.zRotation = 3 * CGFloat.pi/4
//        case .bottomRight:
//            throwDirection = CGVector(dx: 300, dy: -300)
//            projectile.zRotation = 3 * -CGFloat.pi/4
//        }
//        
//        let throwProjectile = SKAction.move(by: throwDirection, duration: 0.25)
//        projectile.run(throwProjectile,
//                       completion: {projectile.removeFromParent()})
//    }
}
