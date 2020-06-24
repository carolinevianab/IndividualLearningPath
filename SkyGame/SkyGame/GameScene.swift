//
//  GameScene.swift
//  SkyGame
//
//  Created by Caroline Viana on 23/06/20.
//  Copyright © 2020 Caroline Viana. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    let persona = SKSpriteNode(imageNamed: "person")
     let rightControl = SKSpriteNode(imageNamed: "rightArrow")
    let leftControl = SKSpriteNode(imageNamed: "leftArrow")
    
    
    override func didMove(to view: SKView) {
        // Adicionando background
        let background = SKSpriteNode(imageNamed: "ground")
        background.position = CGPoint(x: frame.midX, y: frame.midY) //Posição do background
        background.size = frame.size //Tamanho
        addChild(background) //tipo AddSubview
        
        
        let personaSize = persona.frame.height
        persona.size = CGSize(width: persona.size.width * 2, height: persona.size.height * 2)
        persona.position = CGPoint(x: 10, y: 10)
        persona.zPosition = background.zPosition + 1 //Pensar nisso como layers do photoshop
        persona.physicsBody = SKPhysicsBody(circleOfRadius: personaSize)
        addChild(persona) //Criando fisica
        
        //Definição do chão (onde ele fica)
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame.inset(by: UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)))
        
        
        let lcontrolSize = leftControl.size
        leftControl.position = CGPoint(x: frame.minX + lcontrolSize.width / 2, y: frame.minY + lcontrolSize.height / 2)
        leftControl.zPosition = 100
        addChild(leftControl)
        
       
        let rcontrolSize = rightControl.size
        rightControl.position = CGPoint(x: frame.minX + rcontrolSize.width / 2 + lcontrolSize.width, y: frame.minY + rcontrolSize.height / 2)
        rightControl.zPosition = 100
        addChild(rightControl)
        
    }
    
    var touchLocal: CGPoint = CGPoint(x: 0, y: 0)
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchLocal = CGPoint(x: 0, y: 0)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {return}
        touchLocal = touch.location(in: self)
    }
    
    
    
    
    override func update(_ currentTime: TimeInterval) {
        if rightControl.contains(touchLocal){
            persona.position = CGPoint(x: persona.position.x + 5, y: persona.position.y)
        }
        if leftControl.contains(touchLocal){
            persona.position = CGPoint(x: persona.position.x - 5, y: persona.position.y)
        }
    }
}
