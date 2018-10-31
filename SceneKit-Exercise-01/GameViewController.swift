//
//  GameViewController.swift
//  SceneKit-Exercise-01
//
//  Created by Teemu Harju on 06/01/2018.
//  Copyright © 2018 Shipyard Games Oy. All rights reserved.
//

import GameplayKit
import SceneKit
import SpriteKit
import QuartzCore

class GameViewController: NSViewController, SCNSceneRendererDelegate {
    
    var entityManager: EntityManager!
    var lastUpdateTimeInterval: TimeInterval = 0
    let spawnInterval: TimeInterval = 2
    var spawnTime: TimeInterval = 0
    var spawnPosition = SCNVector3(x: 0.0, y: 4.0, z: 0.0)
    
    let colors: [NSColor] = [.red, .yellow, .blue, .green, .magenta]
    
    
    //Game UI
    var gameUI: GKEntity!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // create a new scene
        let scene = SCNScene(named: "art.scnassets/MainScene.scn")!
        
        // retrieve the SCNView
        let scnView = self.view as! SCNView
        scnView.delegate = self
        
        // set the scene to the view
        scnView.scene = scene
        
        // show statistics
        scnView.showsStatistics = true
    
        entityManager = EntityManager(scene: scene)
        let moveSystem = GKComponentSystem(componentClass: MoveComponent.self)
        entityManager.add(moveSystem)
        
        spawnTime = spawnInterval
        
        // init UI
        gameUI = initUI(scnView: scnView)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        
        let deltaTime = time - lastUpdateTimeInterval
        lastUpdateTimeInterval = time
        
        spawnTime += deltaTime
        
        //Added check to see if scene is paused
        if spawnTime > spawnInterval && entityManager.scene.isPaused == false {
            
            spawnTime = 0
            spawnBox(spawnPosition)
        }
        
        entityManager.update(deltaTime)
    }
    
    func initUI(scnView: SCNView) -> GKEntity{
        
        //Create UI entity
        let UIEntity = GKEntity()
        
        //Add UI Component to entity
        let UIComp = UIComponent(view: scnView, entityManager: entityManager, size: view.frame.size, colorMatchIndicatorSize: CGSize(width: 50, height: 50), colors: colors)
        
        UIEntity.addComponent(UIComp)
        
        //Create node for entity to be added to scene by entityManager
        let node = UIComp.node
        node.position = SCNVector3.init(x: 0.0, y: 0.0, z: 0.0)
        node.entity = UIEntity
        
        let nodeComponent = NodeComponent(node: node)
        UIEntity.addComponent(nodeComponent)
        
        entityManager.add(UIEntity)
        
        return UIEntity
    }
    
    func spawnBox(_ position: SCNVector3) {
        
        // Create a box entity
        let boxEntity = GKEntity()
        
        // Pick a random color
        let colors: [NSColor] = [.red, .yellow, .blue, .green, .magenta]
        let color = colors[GKARC4RandomSource().nextInt(upperBound: colors.count)]
        
        // Add a box component to the box entity
        // The BoxComponent creates a box node
        let boxComponent = BoxComponent(width: 1, height: 1, length: 1, boxColor: color)
        boxEntity.addComponent(boxComponent)
        
        let node = boxComponent.node
        node.position = position
        node.entity = boxEntity
        
        // Add a NodeComponent so that the EntityManager adds the
        // box node to the scene
        let nodeComponent = NodeComponent(node: node)
        boxEntity.addComponent(nodeComponent)
        
        // Add a MoveComponent to move the box around
        let moveComponent = MoveComponent(node: node)
        boxEntity.addComponent(moveComponent)
        
        // Add a physics component to make the box fall down
        let physicsComponent = PhysicsComponent(node: node)
        boxEntity.addComponent(physicsComponent)
        
        entityManager.add(boxEntity)
        
    }
    
     override func mouseUp(with event: NSEvent) {
        // retrieve the SCNView
        let scnView = self.view as! SCNView
        
        // check what nodes are clicked
        let p = view.convert(event.locationInWindow, from: nil)
        // using categorybitmask we only check hits with boxes
        let hitResults = scnView.hitTest(p, options: [SCNHitTestOption.categoryBitMask : BoxComponent.bitMask])
        // check that we clicked on at least one object
        if hitResults.count > 0 {
            // retrieved the first clicked object
            let result = hitResults[0]
            
            // get its material
            let node = result.node
            let material = node.geometry!.firstMaterial!
            
            
            // highlight it
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.5
            
            // on completion - unhighlight
            SCNTransaction.completionBlock = {
                SCNTransaction.begin()
                
                if let entity = node.entity {
                    self.entityManager.remove(entity)
                }
                
                SCNTransaction.commit()
            }
            
            CheckScore(node: node, gameUI: self.gameUI)
            
            material.emission.contents = node.entity?.component(ofType: BoxComponent.self)!.nsColor.cgColor
            SCNTransaction.commit()
        }
    }
    
    //Check if colors match and update score accordingly
    func CheckScore(node: SCNNode, gameUI: GKEntity) {
        if node.entity?.component(ofType: BoxComponent.self)!.nsColor.cgColor == gameUI.component(ofType: UIComponent.self)!.GetIndicatorColor() {
            gameUI.component(ofType: UIComponent.self)!.UpdateScore(score: 1)
        }
        else {
            gameUI.component(ofType: UIComponent.self)!.UpdateScore(score: -1)
        }
    }
}
