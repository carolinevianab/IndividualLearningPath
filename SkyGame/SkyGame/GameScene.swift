//
//  GameScene.swift
//  SkyGame
//
//  Created by Caroline Viana on 23/06/20.
//  Copyright © 2020 Caroline Viana. All rights reserved.
//

import SpriteKit

enum CollisionType: UInt32{
    case ground = 1
    case player = 2
    case enemy = 4
}

class GameScene: SKScene {
    let persona = SKSpriteNode(imageNamed: "person")
    let rightControl = SKSpriteNode(imageNamed: "rightArrow")
    let leftControl = SKSpriteNode(imageNamed: "leftArrow")
    let jumpControl = SKSpriteNode(imageNamed: "jump")
    let balinha = SKSpriteNode(imageNamed: "pewpew")
    let ground = SKSpriteNode(imageNamed: "ground2")
    
    
    override func didMove(to view: SKView) {
        // Adicionando background
        let background = SKSpriteNode(imageNamed: "ground")
        background.position = CGPoint(x: frame.midX, y: frame.midY) //Posição do background
        background.size = frame.size //Tamanho
        addChild(background) //tipo AddSubview
        
//        ground.position = CGPoint(x: frame.midX, y: frame.midY)
//        //ground.size = frame.size
//        ground.zPosition = background.zPosition + 1
//        ground.physicsBody?.categoryBitMask = CollisionType.ground.rawValue
//        ground.physicsBody?.collisionBitMask = CollisionType.player.rawValue
//        addChild(ground)
//        ground.physicsBody = SKPhysicsBody(edgeLoopFrom: frame.inset(by: UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)))
        
        
        //let personaSize = persona.frame.width
        persona.size = CGSize(width: persona.size.width * 2, height: persona.size.height * 2)
        persona.position = CGPoint(x: 10, y: 10)
        persona.zPosition = background.zPosition + 1 //Pensar nisso como layers do photoshop
        //persona.physicsBody = SKPhysicsBody(circleOfRadius: personaSize)
        persona.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 100, height: persona.frame.height))
        addChild(persona) //Criando fisica
        persona.physicsBody?.allowsRotation = false
        
        // O que o objeto é no mundo fisico
        persona.physicsBody?.categoryBitMask = CollisionType.player.rawValue
        // Com o que colide
        persona.physicsBody?.collisionBitMask = CollisionType.ground.rawValue | CollisionType.enemy.rawValue
        // O que, quando colide, nós queremos saber
        //persona.physicsBody?.contactTestBitMask
        
        //Definição do chão (onde ele fica)
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame.inset(by: UIEdgeInsets(top: 10, left: 0, bottom: 30, right: 0)))
        
        
        let lcontrolSize = leftControl.size
        leftControl.position = CGPoint(x: frame.minX + lcontrolSize.width / 2, y: frame.minY + lcontrolSize.height / 2)
        leftControl.zPosition = 100
        addChild(leftControl)
        
       
        let rcontrolSize = rightControl.size
        rightControl.position = CGPoint(x: frame.minX + rcontrolSize.width / 2 + lcontrolSize.width, y: frame.minY + rcontrolSize.height / 2)
        rightControl.zPosition = 100
        addChild(rightControl)
        
        let jumpSize = jumpControl.size
        jumpControl.position = CGPoint(x: frame.maxX - jumpSize.width / 2, y: frame.minY + jumpSize.height / 2)
        jumpControl.zPosition = 100
        addChild(jumpControl)
        
        
        
    }
    
    var touchLocal: CGPoint = CGPoint(x: 0, y: 0)
    var jumpYes = false
       var didJump = false
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchLocal = CGPoint(x: 0, y: 0)
        didJump = false
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {return}
        touchLocal = touch.location(in: self)
    }
    
   
    
    
    override func update(_ currentTime: TimeInterval) {
        if rightControl.contains(touchLocal){
            //persona.position = CGPoint(x: persona.position.x + 5, y: persona.position.y)
            persona.run(SKAction.move(to: CGPoint(x: persona.position.x + 30, y: persona.position.y), duration: 0.1))
        }
        if leftControl.contains(touchLocal){
            //persona.position = CGPoint(x: persona.position.x - 5, y: persona.position.y)
            persona.run(SKAction.move(to: CGPoint(x: persona.position.x - 30, y: persona.position.y), duration: 0.1))
        }
        if(jumpControl.contains(touchLocal)){
            if(!didJump){
                didJump = true
                jumpYes = true
            }
            
        }

        if (jumpYes == true){
            var i = 0
            while i < 20 {
                if(rightControl.contains(touchLocal)){
                    persona.physicsBody?.applyImpulse(CGVector(dx: persona.physicsBody?.velocity.dx ?? 0, dy: 50))
                }
                else {
                    persona.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 50))
                }
                i = i + 1
            }
             jumpYes = false
            
            print("persona: \(persona.position.x)\n Frame max x: \(frame.maxX)\n")
        }
        
        if(persona.position.x >= 350){
            touchLocal = CGPoint(x: 0, y: 0)
            persona.position.x = -350
        }
    }
}
