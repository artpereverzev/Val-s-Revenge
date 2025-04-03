//
//  GameScene+ViewUpdates.swift
//  valsrevenge
//
//  Created by Artem Pereverzev on 28.03.2025.
//  Copyright © 2025 Just Write Code LLC. All rights reserved.
//

import SpriteKit

extension GameScene: GameViewControllerDelegate {
  
  func didChangeLayout() {
    let w = view?.bounds.size.width ?? 1024
    let h = view?.bounds.size.height ?? 1336
    
    if h >= w { // portrait, which matches the design
      camera?.setScale(1.0)
    } else {
      camera?.setScale(1.25) // helps to keep relative size
      // larger numbers results in "smaller" scenes
    }
  }
}
