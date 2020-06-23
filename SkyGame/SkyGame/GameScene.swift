//
//  GameScene.swift
//  SkyGame
//
//  Created by Caroline Viana on 23/06/20.
//  Copyright © 2020 Caroline Viana. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
    
    
    override func didMove(to view: SKView) {
        // Adicionando background
        let background = SKSpriteNode(imageNamed: "ground")
        background.position = CGPoint(x: frame.midX, y: frame.midY) //Posição do background
        background.size = frame.size //Tamanho
        addChild(background) //tipo AddSubview
        
        let persona = SKSpriteNode(imageNamed: "person")
        let personaSize = persona.frame.height
        persona.size = CGSize(width: persona.size.width * 2, height: persona.size.height * 2)
        persona.position = CGPoint(x: 10, y: 10)
        persona.zPosition = background.zPosition + 1 //Pensar nisso como layers do photoshop
        persona.physicsBody = SKPhysicsBody(circleOfRadius: personaSize)
        addChild(persona) //Criando fisica
        
        //Definição do chão (onde ele fica)
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame.inset(by: UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)))
        
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
