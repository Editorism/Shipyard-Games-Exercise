//
//  UIComponent.swift
//  SceneKit-Exercise-01
//
//  Created by Emil Dewald on 29.10.2018.
//  Copyright © 2018 Shipyard Games Oy. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit

class UIComponent: GKComponent{
    
    let colorChangeInterval: TimeInterval = 10
    
    let skScene: SKScene
    
    var score = 0
    lazy var scoreLabel : SKLabelNode = {
        var label = SKLabelNode(fontNamed: "SanFrancisco")
        label.fontSize = 50
        label.fontColor = NSColor.black
        label.position = CGPoint(x: skScene.frame.midX, y: 50)
        label.text = "Score: \(String(score))"
        return label
    }()
    
    lazy var finishLabel : SKLabelNode = {
        var label = SKLabelNode(fontNamed: "SanFrancisco")
        label.fontSize = 50
        label.fontColor = NSColor.black
        label.numberOfLines = 0
        label.position = CGPoint(x: skScene.frame.midX, y: skScene.frame.midY)
        label.text = "Game Over \nFinal score: \(String(score))"
        return label
    }()
    
    lazy var countdownLabel : SKLabelNode = {
        var label = SKLabelNode(fontNamed: "SanFrancisco")
        label.fontSize = 50
        label.fontColor = NSColor.black
        label.position = CGPoint(x: skScene.frame.midX, y: skScene.frame.maxY - 50)
        counter = counterTimeLimit
        label.text = "\(counter)"
        return label
    }()
    
    var counter = 0;
    var counterTimer = Timer()
    let counterTimeLimit = 60
    var gameOver = false;
    
    let colorMatchIndicator: SKSpriteNode
    var colorTimer = Timer()
    let colors: [NSColor]
    
    let node: SCNNode
    let entityManager: EntityManager
    
    init(view: SCNView, entityManager: EntityManager, size: CGSize, colorMatchIndicatorSize: CGSize, colors: [NSColor]){
        
        node = SCNNode()
        node.name = "UI"
        
        skScene = SKScene(size: size)
        skScene.isUserInteractionEnabled = false
        
        self.colors = colors
        
        let color = colors[GKARC4RandomSource().nextInt(upperBound: colors.count)]
        colorMatchIndicator = SKSpriteNode(color: color, size: colorMatchIndicatorSize)
        colorMatchIndicator.position = CGPoint(x: skScene.frame.maxX - 50, y: skScene.frame.maxY - 50)
        
        self.entityManager = entityManager
        
        super.init()
        
        skScene.addChild(colorMatchIndicator)
        skScene.addChild(scoreLabel)
        skScene.addChild(countdownLabel)
        
        view.overlaySKScene = skScene
        
        StartColorTimer()
        StartCounterTimer()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func UpdateScore(score: Int){
        self.score += score
        if(self.score < 0) {
            self.score = 0
        }
        scoreLabel.text = "Score: \(String(self.score))"
    }
    
    func StartCounterTimer() {
        counterTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(decrementCounter), userInfo: nil, repeats: true)
    }
    
    func StartColorTimer() {
        colorTimer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(ChangeMatchIndicatorColor), userInfo: nil, repeats: true)
    }
    
    func StopTimers() {
        counterTimer.invalidate()
        colorTimer.invalidate()
    }
    
    @objc func decrementCounter() {
        
        if !gameOver{
            counter -= 1
            countdownLabel.text = "\(counter)"
            
            if counter == 0 {
                gameOver = true
                GameOver()
            }
        }
    }
    
    
    //Randomize color of the color match indicator
    @objc func ChangeMatchIndicatorColor() {
        var color = colors[GKARC4RandomSource().nextInt(upperBound: colors.count)]
        while colorMatchIndicator.color.cgColor == color.cgColor {
            color = colors[GKARC4RandomSource().nextInt(upperBound: colors.count)]
        }
        colorMatchIndicator.color = color
    }
    
    //Used to check the color of the indicator against the box color
    func GetIndicatorColor() -> CGColor{
        return colorMatchIndicator.color.cgColor
    }
    
    func GameOver(){
        StopTimers()
        skScene.isUserInteractionEnabled = true
        skScene.removeAllChildren()
        skScene.addChild(finishLabel)
        entityManager.scene.isPaused = true
    }
}
