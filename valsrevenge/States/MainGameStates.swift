//
//  MainGameStates.swift
//  valsrevenge
//
//  Created by Artem Pereverzev on 26.03.2025.
//  Copyright © 2025 Just Write Code LLC. All rights reserved.
//
import GameplayKit

class PauseState: GKState {
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass == PlayingState.self
    }
    
}

class PlayingState: GKState {
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass == PauseState.self
    }
    
}
