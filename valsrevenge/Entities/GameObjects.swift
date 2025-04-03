//
//  Entities.swift
//  valsrevenge
//
//  Created by Artem Pereverzev on 24.03.2025.
//  Copyright © 2025 Just Write Code LLC. All rights reserved.
//
import SpriteKit
import GameplayKit

enum GameObjectType: String {
    
    // Monsters
    case skeleton
    case goblin
    case pawn
    
    // Collectibles
    case key
    case food
    case treasure
}

struct GameObject {
    static let defaultGeneratorType = GameObjectType.skeleton.rawValue
    static let defaultAnimationType = GameObjectType.skeleton.rawValue
    static let defaultCollectibleType = GameObjectType.key.rawValue
    static let defaultExperienceType = GameObjectType.skeleton.rawValue
    
    static let skeleton = Skeleton()
    static let goblin = Goblin()
    static let pawn = Pawn()
    
    static let key = Key()
    static let food = Food()
    static let treasure = Treasure()
    
    struct Goblin {
        let animationSettings = Animation(textures: SKTexture.loadTextures(atlas: "monster_goblin",
                                                                           prefix: "goblin_",
                                                                           startsAt: 0,
                                                                           stopAt: 1))
        let experienceAmount = 25
    }
    
    struct Skeleton {
        let animationSettings = Animation(textures: SKTexture.loadTextures(atlas: "monster_skeleton",
                                                                           prefix: "skeleton_",
                                                                           startsAt: 0,
                                                                           stopAt: 1),
                                          timePerFrame: TimeInterval(1.0 / 25.0))
        let experienceAmount = 10
    }
    
    struct Pawn {
        let animationSettings = Animation(textures: SKTexture.loadTextures(atlas: "monster_pawn",
                                                                           prefix: "pawn_",
                                                                           startsAt: 0,
                                                                           stopAt: 5),
                                          timePerFrame: TimeInterval(1.0 / 25.0))
        let experienceAmount = 35
    }
    
    struct Key {
        let collectibleSettings = Collectible(type: .key,
                                              collectSoundFile: "key",
                                              destroySoundFile: "destroyed")
    }
    
    struct Food {
        let collectibleSettings = Collectible(type: .food,
                                              collectSoundFile: "food",
                                              destroySoundFile: "destroyed",
                                              canDestroy: true)
    }
    
    struct Treasure {
        let collectibleSettings = Collectible(type: .treasure, collectSoundFile: "treasure", destroySoundFile: "destroyed")
    }
    
    static func forExperienceType(_ type: GameObjectType?) -> Int? {
        switch type {
        case .goblin:
            return GameObject.goblin.experienceAmount
        case .skeleton:
            return GameObject.skeleton.experienceAmount
        case .pawn:
            return GameObject.pawn.experienceAmount
        default:
            return 0
        }
    }
    
    static func forAnimationType(_ type: GameObjectType?) -> Animation? {
        switch type {
        case .goblin:
            return GameObject.goblin.animationSettings
        case .skeleton:
            return GameObject.skeleton.animationSettings
        case .pawn:
            return GameObject.pawn.animationSettings
        default:
            return nil
        }
    }
    
    static func forCollectibleType(_ type: GameObjectType?) -> Collectible? {
        switch type {
        case .key:
            return GameObject.key.collectibleSettings
        case .food:
            return GameObject.food.collectibleSettings
        case .treasure:
            return GameObject.treasure.collectibleSettings
        default:
            return nil
        }
    }
    
}
