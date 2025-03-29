//
//  SKTexture+LoadTextures.swift
//  valsrevenge
//
//  Created by Artem Pereverzev on 24.03.2025.
//  Copyright © 2025 Just Write Code LLC. All rights reserved.
//
import SpriteKit

extension SKTexture {
    static func loadTextures(atlas: String, prefix: String, startsAt: Int, stopAt: Int) -> [SKTexture] {
        
        var textureArray = [SKTexture]()
        let textureAtlas = SKTextureAtlas(named: atlas)
        
        for i in startsAt...stopAt {
            let textureName = "\(prefix)\(i)"
            let temp = textureAtlas.textureNamed(textureName)
            textureArray.append(temp)
        }
        
        return textureArray
        
    }
}
