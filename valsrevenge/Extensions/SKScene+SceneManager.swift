//
//  SKScene+SceneManager.swift
//  valsrevenge
//
//  Created by Artem Pereverzev on 28.03.2025.
//  Copyright © 2025 Just Write Code LLC. All rights reserved.
//

import SpriteKit
import GameplayKit

extension SKScene {
    
    func startNewGame() {
        // Reset saved game data
        GameData.shared.level = 3
        
        GameData.shared.keys = 0
        GameData.shared.treasure = 0
        
        // Load level
        loadSceneForLevel(GameData.shared.level)
    }
    
    func resumeSavedGame() {
        loadSceneForLevel(GameData.shared.level)
    }
    
    func loadSceneForLevel(_ level: Int) {
        print("Attempting to load next scene: GameScene_\(level).")
        
        // Play sound
        run(SKAction.playSoundFileNamed("exit", waitForCompletion: true))
        
        // Create actions to load the next scene
        let wait = SKAction.wait(forDuration: 0.50)
        let block = SKAction.run {
            
            // Load 'GameScene_xx.sks' as a GKScene
            if let scene = GKScene(fileNamed: "GameScene_\(level)") {
                print("Loading the next scene: GameScene_\(level).")
                // Get the SKScene from the loaded GKScene
                if let sceneNode = scene.rootNode as! GameScene? {
                    
                    print("Getting the SKScene from the loaded GKScene")
                    // Copy gameplay related content over to the scene
                    sceneNode.entities = scene.entities
                    sceneNode.graphs = scene.graphs
                    
                    // Set the scale mode to scale to fit the window
                    sceneNode.scaleMode = .aspectFill
                    
                    // Present the scene
                    self.view?.presentScene(sceneNode, transition:
                                                SKTransition.doorsOpenHorizontal(withDuration: 1.0))
                    
                    // Update the layout
                    sceneNode.didChangeLayout()
                    print("CHANGING LAYOUT")
                }
            } else {
                print("Can't load next scene: GameScene_\(level).")
            }
        }
        
        // Run the actions in sequence
        run(SKAction.sequence([wait, block]))
    }
    
    func loadGameOverScene() {
        print("Attempting to load the game over scene.")
        
        // Create actions to load the game over scene
        let wait = SKAction.wait(forDuration: 0.50)
        let block = SKAction.run {
            if let scene = GameOverScene(fileNamed: "GameOverScene") {
                scene.scaleMode = .aspectFill
                
                self.view?.presentScene(scene, transition:
                                            SKTransition.doorsOpenHorizontal(withDuration: 1.0))
            } else {
                print("Can't load game over scene.")
            }
        }
        
        // Run the actions in sequence
        run(SKAction.sequence([wait, block]))
    }
    
    func loadSkillTreeScene() {
        print("Attempting to load skill tree scene.")
        
        // Create actions to load the game over scene
        let wait = SKAction.wait(forDuration: 0.50)
        let block = SKAction.run {
            if let scene = SkillTreeScene(fileNamed: "SkillTreeScene") {
                scene.scaleMode = .aspectFill
                
                self.view?.presentScene(scene, transition:
                                            SKTransition.doorsOpenHorizontal(withDuration: 1.0))
            } else {
                print("Can't load skill tree scene.")
            }
        }
        
        // Run the actions in sequence
        run(SKAction.sequence([wait, block]))
    }
}
