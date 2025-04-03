//
//  AttackComponent.swift
//  valsrevenge
//
//  Created by Artem Pereverzev on 01.04.2025.
//  Copyright © 2025 Just Write Code LLC. All rights reserved.
//
import SpriteKit
import GameplayKit

enum AttackType: String {
    case range
    case melee
    case magic
}

enum WeaponType: String {
    case sword
    case throwKnife
    case fireball
    case iceball
    case bow
}

struct Weapon {
    
}

class AttackComponent: GKComponent {
    
    @GKInspectable var weaponType: String = WeaponType.throwKnife.rawValue
    @GKInspectable var attackType: String = AttackType.range.rawValue
    
    var maxProjectiles: Int = 1
    var numProjectiles: Int = 0
    
    var projectileSpeed: CGFloat = 300
    var projectileRange: TimeInterval = 1
    
    let attackDelay = SKAction.wait(forDuration: 1.0)
    var enemyProjectile = SKSpriteNode()
    
    func rangeAttack(direction: CGVector, emitterNamed: String?, type: WeaponType?) {
        
        //        guard let player = componentNode as? Player else {
        //            return
        //        }
        
        // Verify the direction isn't zero and that the player hasn't
        // shot more projectiles than the max allowed at one time
        if direction != .zero && numProjectiles < maxProjectiles {
            
            // Increase the number of "current" projectiles
            numProjectiles += 1
            
            // Setup the projectile type
            switch type {
            case .throwKnife:
                enemyProjectile = SKSpriteNode(imageNamed: "knife")
            case .fireball:
                enemyProjectile = SKSpriteNode(imageNamed: "")
            case .iceball:
                enemyProjectile = SKSpriteNode(imageNamed: "")
            case .sword:
                enemyProjectile = SKSpriteNode(imageNamed: "")
            case .bow:
                enemyProjectile = SKSpriteNode(imageNamed: "")
            default:
                enemyProjectile = SKSpriteNode(imageNamed: "")
            }
            
            //projectile.position = CGPoint(x: 0.0, y: 0.0)
            //enemyProjectile.position = CGPoint(x: 0.0, y: 0.0)
            enemyProjectile.xScale = 0.6
            enemyProjectile.yScale = 0.6
            enemyProjectile.position = componentNode.position
            enemyProjectile.zPosition += 1
            
            // TODO: Need to decide moving to other component? Or create entire attack component with particles, attack type (range/melee etc)?
            // Setup optional particles for projectile
            if let emitterNamed = emitterNamed,
               let particles = SKEmitterNode(fileNamed: emitterNamed) {
                particles.name = "particles"
                particles.position = CGPoint(x: 0.0, y: -20.0)
                enemyProjectile.addChild(particles)
            }
            
            //componentNode.addChild(enemyProjectile)
            componentNode.scene?.addChild(enemyProjectile)
            
            // Setup the physics for the projectile
            let physicsBody = SKPhysicsBody(rectangleOf: enemyProjectile.size)
            
            physicsBody.affectedByGravity = false
            physicsBody.allowsRotation = true
            physicsBody.isDynamic = true
            
            physicsBody.categoryBitMask = PhysicsBody.enemyProjectile.categoryBitMask
            physicsBody.contactTestBitMask = PhysicsBody.enemyProjectile.contactTestBitMask
            physicsBody.collisionBitMask = PhysicsBody.enemyProjectile.collisionBitMask
            
            enemyProjectile.physicsBody = physicsBody
            
            let normalizedDirection = direction.normalized()
            
            //let throwDistance: CGFloat = 1000
            let throwDirection: CGVector
            // Set the throw direction
            throwDirection = CGVector(dx: normalizedDirection.dx * projectileSpeed,
                                      dy: normalizedDirection.dy * projectileSpeed)
            
            // Create and run the actions to attack
            let wait = SKAction.wait(forDuration: projectileRange)
            let removeFromScene = SKAction.removeFromParent()
            
            let spin = SKAction.applyTorque(0.05, duration: projectileRange)//0.25
            let toss = SKAction.move(by: throwDirection, duration: projectileRange)
            
            let actionTTL = SKAction.sequence([wait, removeFromScene])
            let actionThrow = SKAction.group([spin, toss])
            
            let actionAttack = SKAction.group([actionTTL, actionThrow])
            enemyProjectile.run(actionAttack)
            
            // Setup attack govenor (attack speed limiter)
            let reduceCount = SKAction.run({
                self.numProjectiles -= 1
            })
            let reduceSequence = SKAction.sequence([attackDelay, reduceCount])
            componentNode.run(reduceSequence)
        }
    }
    
    func findPlayerPosition() -> CGVector {
        guard let scene = componentNode.scene as? GameScene,
              let player = scene.childNode(withName: "player") as? Player else {
            return .zero
        }
        
        let playerPosition = player.position
        let monsterPosition = componentNode.position
        let dx = playerPosition.x - monsterPosition.x
        let dy = playerPosition.y - monsterPosition.y
        let distance = sqrt(dx * dx + dy * dy)
        
        // Normalize vector from enemy to player
        let normalizedDx = dx / distance
        let normalizedDy = dy / distance
        
        return CGVector(dx: normalizedDx, dy: normalizedDy)
    }
    
    func prepareAttack() {
        // Setup repeating action
        let currentPlayerPosition: CGVector = findPlayerPosition()
        
        rangeAttack(direction: currentPlayerPosition, emitterNamed: "Fire.sks", type: .throwKnife)
    }
    
    func startAttack() {
        let wait = SKAction.wait(forDuration: TimeInterval(1))
        let attack = SKAction.run { [unowned self] in self.prepareAttack() }
        let sequence = SKAction.sequence([wait, attack])
        let repeatAction = SKAction.repeatForever(sequence)
        
        componentNode.run(repeatAction, withKey: "repeatEnemyRangeAttack")
    }
    
    override func didAddToEntity() {
        startAttack()
        //componentNode.removeAction(forKey: "repeatEnemyRangeAttack")
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        
    }
    
    override class var supportsSecureCoding: Bool {
        true
    }
}
