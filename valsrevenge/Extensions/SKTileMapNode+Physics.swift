//
//  SKTileMapNode+Physics.swift
//  valsrevenge
//
//  Created by Artem Pereverzev on 28.03.2025.
//  Copyright © 2025 Just Write Code LLC. All rights reserved.
//

import SpriteKit

extension SKTileMapNode {
    
    func setupEdgeLoop() {
        let mapPoint = CGPoint(x: -frame.size.width/2,
                               y: -frame.size.height/2)
        let mapSize = CGSize(width: frame.size.width,
                             height: frame.size.height)
        let edgeLoopRect = CGRect(origin: mapPoint, size: mapSize)
        
        // Set up physics body
        physicsBody = SKPhysicsBody(edgeLoopFrom: edgeLoopRect)
        
        // Adjust default values
        physicsBody?.affectedByGravity = false
        physicsBody?.allowsRotation = false
        physicsBody?.isDynamic = false
        
        physicsBody?.categoryBitMask = PhysicsBody.wall.categoryBitMask
        physicsBody?.collisionBitMask = PhysicsBody.wall.collisionBitMask
        physicsBody?.contactTestBitMask = PhysicsBody.wall.contactTestBitMask
    }
    
    func setupMapPhysics() {
        let halfWidth = CGFloat(numberOfColumns) / 2.0 * tileSize.width
        let halfHeight = CGFloat(numberOfRows) / 2.0 * tileSize.height
        
        for col in 0..<numberOfColumns {
            for row in 0..<numberOfRows {
                if let td = tileDefinition(atColumn: col, row: row) {
                    
                    if let bodySizeValue = td.userData?.value(forKey: "bodySize")
                        as? String {
                        
                        let x = CGFloat(col) *
                        tileSize.width - halfWidth + (tileSize.width/2)
                        let y = CGFloat(row) *
                        tileSize.height - halfHeight + (tileSize.height/2)
                        
                        let bodySize = NSCoder.cgPoint(for: bodySizeValue) // {x,y}
                        let pSize = CGSize(width: bodySize.x, height: bodySize.y)
                        
                        let tileNode = SKNode()
                        tileNode.position = CGPoint(x: x, y: y)
                        
                        if let bodyOffsetValue = td.userData?.value(forKey: "bodyOffset")
                            as? String {
                            
                            let bodyOffset = NSCoder.cgPoint(for: bodyOffsetValue)
                            tileNode.physicsBody =
                            SKPhysicsBody(rectangleOf: pSize,
                                          center: CGPoint(x: bodyOffset.x, y: bodyOffset.y))
                        } else {
                            tileNode.physicsBody = SKPhysicsBody(rectangleOf: pSize)
                        }
                        
                        // Adjust default values
                        tileNode.physicsBody?.affectedByGravity = false
                        tileNode.physicsBody?.allowsRotation = false
                        tileNode.physicsBody?.isDynamic = false
                        
                        tileNode.physicsBody?.categoryBitMask = PhysicsBody.wall.categoryBitMask
                        tileNode.physicsBody?.collisionBitMask = PhysicsBody.wall.collisionBitMask
                        tileNode.physicsBody?.contactTestBitMask = PhysicsBody.wall.contactTestBitMask
                        
                        // Add node
                        addChild(tileNode)
                    }
                }
            }
        }
    }
}
