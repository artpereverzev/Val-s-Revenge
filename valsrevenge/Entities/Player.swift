//
//  Player.swift
//  valsrevenge
//
//  Created by Artem Pereverzev on 28.03.2025.
//  Copyright © 2025 Just Write Code LLC. All rights reserved.
//

import SpriteKit
import GameplayKit

class Player: SKSpriteNode {
    
    // Player properties
    var stateMachine = GKStateMachine(states: [PlayerHasKeyState(), PlayerHasNoKeyState()])
    
    var movementSpeed: CGFloat = 5
    
    var level = String(GameData.shared.level)
    
    var maxProjectiles: Int = 1
    var numProjectiles: Int = 0
    
    var nodeDirection: String = "R"
    
    var projectileSpeed: CGFloat = 300//25
    var projectileRange: TimeInterval = 1//1
    
    let attackDelay = SKAction.wait(forDuration: 0.25)
    
    var hud = SKNode()
    private let treasureLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
    private let keysLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
    private let levelLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
    private let playerLevelLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
    private let playerExperienceLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
    
    private var keys: Int = GameData.shared.keys {
        didSet {
            keysLabel.text = "Keys: \(keys)"
            if keys < 1 {
                stateMachine.enter(PlayerHasNoKeyState.self)
            } else {
                stateMachine.enter(PlayerHasKeyState.self)
            }
        }
    }
    
    private var treasure: Int = GameData.shared.treasure {
        didSet {
            treasureLabel.text = "Treasure: \(treasure)"
        }
    }
    
    private var playerLevel: Int = GameData.shared.playerLevel {
        didSet {
            playerLevelLabel.text = "Player level: \(playerLevel)"
        }
    }
    
    private var playerExperience: Int = GameData.shared.playerExperience {
        didSet {
            playerExperienceLabel.text = "EXP: \(playerExperience)"
        }
    }
    
    private var playerExperienceToNextLevel: Int {
        get { return playerLevel * 100 }
    }
    
    var agent = GKAgent2D()
    
    // Override this method to allow for a class to work in Scene Editor
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        stateMachine.enter(PlayerHasNoKeyState.self)
        
        agent.delegate = self
    }
    
    func getStats() -> (keys: Int, treasure: Int) {
        return (self.keys, self.treasure)
    }
    
    func flipPlayerSpriteDirection(direction: CGVector) {
        if direction.dx < 0 {
            nodeDirection = "L"
            self.xScale = -abs(xScale)
        } else {
            nodeDirection = "R"
            self.xScale = abs(xScale)
        }
    }
    
    func flipPlayerSpriteDirection(direction: String) {
        if direction == "L" {
            nodeDirection = "L"
            self.xScale = -abs(xScale)
        } else {
            nodeDirection = "R"
            self.xScale = abs(xScale)
        }
    }
    
    func rotatePlayerSpriteDirection(direction: String) {
        if direction == "L" {
            nodeDirection = "L"
            self.zRotation = -(CGFloat(Double.pi/2))
        } else {
            nodeDirection = "R"
            self.zRotation = -(CGFloat(Double.pi/2))
        }
    }
    
    func setupAnimation() {
        let animationSettings = Animation(textures: SKTexture.loadTextures(atlas: "player_val",
                                                                           prefix: "hero_",
                                                                           startsAt: 0,
                                                                           stopAt: 6))
        
        let textures = animationSettings.textures
        let timePerFrame = animationSettings.timePerFrame
        let animationAction = SKAction.animate(with: textures, timePerFrame: timePerFrame)
        
        if animationSettings.repeatTexturesForever == true {
            let repeatAction = SKAction.repeatForever(animationAction)
            self.run(repeatAction)
        } else {
            self.run(animationAction)
        }
        
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
        
        // Setup the player level label
        playerLevelLabel.text = "Player level: \(playerLevel)"
        playerLevelLabel.horizontalAlignmentMode = .right
        playerLevelLabel.verticalAlignmentMode = .center
        playerLevelLabel.position = CGPoint(x: 0, y: treasureLabel.frame.minY - (keysLabel.frame.height * 3.1))
        playerLevelLabel.zPosition += 1
        
        // Setup the player experience label
        playerExperienceLabel.text = "Experience: \(playerExperience)"
        playerExperienceLabel.horizontalAlignmentMode = .right
        playerExperienceLabel.verticalAlignmentMode = .center
        playerExperienceLabel.position = CGPoint(x: 0, y: treasureLabel.frame.minY - (keysLabel.frame.height * 4.1))
        playerExperienceLabel.zPosition += 1
        
        // Add labels to the HUD
        hud.addChild(treasureLabel)
        hud.addChild(keysLabel)
        hud.addChild(levelLabel)
        hud.addChild(playerLevelLabel)
        hud.addChild(playerExperienceLabel)
        
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
            keys += collectible.value
            
        case .food:
            if let hc = entity?.component(ofType: HealthComponent.self) {
                hc.updateHealth(collectible.value, forNode: self)
            }
            
        case .treasure:
            treasure += collectible.value
            
        default:
            break
        }
    }
    
    func useKeyToOpenDoor(_ doorNode: SKNode) {
        
        switch stateMachine.currentState {
        case is PlayerHasKeyState:
            keys -= 1
            
            doorNode.removeFromParent()
            run(SKAction.playSoundFileNamed("door_open", waitForCompletion: true))
            
        default:
            break
        }
    }
    
    func addExperience(_ experience: Int) {
        playerExperience += experience
        checkLevelUp()
    }
    
    private func checkLevelUp() {
        print("playerExperience: \(playerExperience)\nplayerExperienceToNextLevel: \(playerExperienceToNextLevel)")
        if playerExperience >= playerExperienceToNextLevel {
            playerExperience -= playerExperienceToNextLevel
            playerLevel += 1
            onLevelUp() // Modify
        }
    }
    
    private func onLevelUp() {
        print("Level up!: \(playerLevel)")
    }

    
    func attack(direction: CGVector, emitterNamed: String?) {
        
        // Verify the direction isn't zero and that the player hasn't
        // shot more projectiles than the max allowed at one time
        if direction != .zero && numProjectiles < maxProjectiles {
            
            // Increase the number of "current" projectiles
            numProjectiles += 1
            
            // Setup the projectile
            let projectile = SKSpriteNode(imageNamed: "knife")
            projectile.position = self.position
            projectile.xScale = 0.6
            projectile.yScale = 0.6
            projectile.zPosition += 1
            
            // TODO: Need to decide moving to other component? Or create entire attack component with particles, attack type (range/melee etc)?
            // Setup optional particles for projectile
            if let emitterNamed = emitterNamed,
               let particles = SKEmitterNode(fileNamed: emitterNamed) {
                particles.name = "particles"
                particles.position = CGPoint(x: 0.0, y: -20.0)
                projectile.addChild(particles)
            }
            
            scene?.addChild(projectile)
            
            // Setup the physics for the projectile
            let physicsBody = SKPhysicsBody(rectangleOf: projectile.size)
            
            physicsBody.affectedByGravity = false
            physicsBody.allowsRotation = true
            physicsBody.isDynamic = true
    
            physicsBody.categoryBitMask = PhysicsBody.projectile.categoryBitMask
            physicsBody.contactTestBitMask = PhysicsBody.projectile.contactTestBitMask
            physicsBody.collisionBitMask = PhysicsBody.projectile.collisionBitMask
            
            projectile.physicsBody = physicsBody
            
            let normalizedDirection = direction.normalized()// TEST
            
            // Set the throw direction
            let throwDirection = CGVector(
                dx: normalizedDirection.dx * projectileSpeed,
                dy: normalizedDirection.dy * projectileSpeed
            )
            
            // Create and run the actions to attack
            let soundThrowKnife = SKAction.playSoundFileNamed("throw", waitForCompletion: false)
            let wait = SKAction.wait(forDuration: projectileRange)
            let removeFromScene = SKAction.removeFromParent()
            
            let spin = SKAction.applyTorque(0.05, duration: projectileRange)//0.25, coulde be different because of node scale?
            let toss = SKAction.move(by: throwDirection, duration: projectileRange)
            
            let actionTTL = SKAction.sequence([wait, removeFromScene])
            let actionThrow = SKAction.group([soundThrowKnife, spin, toss])
            
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
}
