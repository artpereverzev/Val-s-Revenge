//
//  Controller.swift
//  valsrevenge
//
//  Created by Artem Pereverzev on 28.03.2025.
//  Copyright © 2025 Just Write Code LLC. All rights reserved.
//
import SpriteKit

class Controller: SKReferenceNode {
    
    private var isMovement: Bool!
    
    private var attachedNode: SKNode!
    private var nodeSpeed: CGFloat!
    
    private var base: SKNode!
    private var joystick: SKSpriteNode!
    private var range: CGFloat!
    
    private var isTracking: Bool = false
    
    // MARK: - Controller init
    
    convenience init(stickImage: SKSpriteNode?, attachedNode: SKNode, nodeSpeed: CGFloat = 0.0, isMovement: Bool = true, range: CGFloat = 55.0, color: SKColor)
    
}
