//
//  Entities.swift
//  valsrevenge
//
//  Created by Artem Pereverzev on 04.04.2025.
//  Copyright © 2025 Just Write Code LLC. All rights reserved.
//

import SpriteKit
import GameplayKit

// MARK: - Game object types
enum GameObjectType: String, CaseIterable {
    // Monsters
    case skeleton
    case goblin
    case pawn
    
    // Collectibles
    case key
    case food
    case treasure
}

// MARK: - Protocols for entities
protocol AnimationData {
    var textures: [SKTexture] { get }
    var timePerFrame: TimeInterval { get }
    var repeatForever: Bool { get }
    var repeatTexturesForever: Bool { get }
}

protocol ExperienceData {
    var experienceAmount: Int { get }
}

protocol CollectibleData {
    var collectSound: String { get }
    var destroySound: String { get }
    var canDestroy: Bool { get }
}

// MARK: - Basic configuration for entities
struct GameObjectConfig {
    private static let configs: [GameObjectType: Any] = [
        // Monsters
        .goblin: (
            animation: AnimationDataImpl(
                atlas: "monster_goblin",
                prefix: "goblin_",
                range: 0...1,
                fps: 10
            ),
            experience: ExperienceDataImpl(experienceAmount: 25)
        ),
        
        .skeleton: (
            animation: AnimationDataImpl(
                atlas: "monster_skeleton",
                prefix: "skeleton_",
                range: 0...1,
                fps: 25
            ),
            experience: ExperienceDataImpl(experienceAmount: 10)
        ),
        
        .pawn: (
            animation: AnimationDataImpl(
                atlas: "monster_pawn",
                prefix: "pawn_",
                range: 0...5,
                fps: 25
            ),
            experience: ExperienceDataImpl(experienceAmount: 35)
        ),
        
        // Collectibles
        .key: CollectibleDataImpl(
            collectSound: "key",
            destroySound: "destroyed",
            canDestroy: false
        ),
        
        .food: CollectibleDataImpl(
            collectSound: "food",
            destroySound: "destroyed",
            canDestroy: true
        ),
        
        .treasure: CollectibleDataImpl(
            collectSound: "treasure",
            destroySound: "destroyed",
            canDestroy: false
        )
    ]
    
    // Adding protocols for struct
    private struct AnimationDataImpl: AnimationData {
        let textures: [SKTexture]
        let timePerFrame: TimeInterval
        let repeatForever: Bool = true
        let repeatTexturesForever: Bool = true
        
        init(atlas: String, prefix: String, range: ClosedRange<Int>, fps: Int) {
            self.textures = SKTexture.loadTextures(
                atlas: atlas,
                prefix: prefix,
                startsAt: range.lowerBound,
                stopAt: range.upperBound
            )
            self.timePerFrame = 1.0 / TimeInterval(fps)
        }
    }
    
    private struct ExperienceDataImpl: ExperienceData {
        let experienceAmount: Int
    }
    
    private struct CollectibleDataImpl: CollectibleData {
        let collectSound: String
        let destroySound: String
        let canDestroy: Bool
    }
    
    // MARK: - Public methods
    
    static func animation(for type: GameObjectType) -> AnimationData? {
        guard let config = configs[type] as? (animation: AnimationData, experience: ExperienceData) else {
            return configs[type] as? AnimationData
        }
        return config.animation
    }
    
    static func experience(for type: GameObjectType) -> Int {
        guard let config = configs[type] as? (animation: AnimationData, experience: ExperienceData) else {
            return 0
        }
        return config.experience.experienceAmount
    }
    
    static func collectible(for type: GameObjectType) -> CollectibleData? {
        return configs[type] as? CollectibleData
    }
    
    static var defaultGeneratorType: GameObjectType { .skeleton }
    static var defaultAnimationType: GameObjectType { .skeleton }
    static var defaultCollectibleType: GameObjectType { .key }
    static var defaultExperienceType: GameObjectType { .skeleton }
}
