//
//  GKComponent+Node.swift
//  valsrevenge
//
//  Created by Artem Pereverzev on 23.03.2025.
//  Copyright © 2025 Just Write Code LLC. All rights reserved.
//
import SpriteKit
import GameplayKit

extension GKComponent {
    
    var componentNode: SKNode {
        if let node = entity?.component(ofType: GKSKNodeComponent.self)?.node {
            return node
        } else if let node = entity?.component(ofType: RenderComponent.self)?.spriteNode {
            return node
        }
        
        return SKNode()
    }
    
}
