//
//  MoveComponent.swift
//  SceneKit-Exercise-01
//
//  Created by Andreas Wedenberg on 07/01/2018.
//  Copyright © 2018 Shipyard Games Oy. All rights reserved.
//

import GameplayKit
import SceneKit

class MoveComponent: GKComponent {
    
    var node: SCNNode!
    let movementInterval: TimeInterval = 3
    
    private var time: TimeInterval = 0
    
    init(node: SCNNode) {
        self.node = node
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        super.update(deltaTime: seconds)

        time += seconds
        
        if time > movementInterval {
            time = 0
            
            // Box movement randomizer
            let randomizer = GKARC4RandomSource()
            let randomMagnitudeX: CGFloat = randomizer.nextBool() ? 2.0 : -2.0
            let randomMagnitudeZ: CGFloat = randomizer.nextBool() ? 2.0 : -2.0
            let randX = CGFloat(randomizer.nextUniform()) * randomMagnitudeX
            let randZ = CGFloat(randomizer.nextUniform()) * randomMagnitudeZ
            
            node.physicsBody?.applyForce(SCNVector3(randX,3,randZ), asImpulse: true)
        }
        
    }
}

