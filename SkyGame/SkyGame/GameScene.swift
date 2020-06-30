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
    case weapon = 8
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    let player = SKSpriteNode(imageNamed: "person")
    let background = SKSpriteNode(imageNamed: "ground")
    let rightControl = SKSpriteNode(imageNamed: "rightArrow")
    let leftControl = SKSpriteNode(imageNamed: "leftArrow")
    let jumpControl = SKSpriteNode(imageNamed: "jump")
    let ground = SKSpriteNode(imageNamed: "ground2")
    let enemy = SKSpriteNode(imageNamed: "enemy")
    
    var touchLocal: CGPoint = CGPoint(x: 0, y: 0)
    var jumpYes = false
    var didJump = false
    var isPlayerAlive = true
    var lastFire: Double = 0
    
    
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        // Adicionando background
        //Posição do background
        background.position = CGPoint(x: frame.midX, y: frame.midY)
        //Tamanho
        background.size = frame.size
        //tipo AddSubview
        addChild(background)
        
        
        player.size = CGSize(width: player.size.width * 2, height: player.size.height * 2)
        player.position = CGPoint(x: 10, y: 10)
        //Pensar nisso como layers do photoshop
        player.zPosition = background.zPosition + 1
        //Criando fisica
        player.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 100, height: player.frame.height))
        addChild(player)
        
        
        player.physicsBody?.allowsRotation = false
        // O que o objeto é no mundo fisico
        player.physicsBody?.categoryBitMask = CollisionType.player.rawValue
        // Com o que colide
        player.physicsBody?.collisionBitMask = CollisionType.ground.rawValue | CollisionType.enemy.rawValue
        // O que, quando colide, nós queremos saber
        player.physicsBody?.contactTestBitMask = CollisionType.enemy.rawValue
        player.name = "player"
        
        
        let lcontrolSize = leftControl.size
        leftControl.position = CGPoint(x: frame.minX + lcontrolSize.width / 2, y: frame.minY + lcontrolSize.height / 2)
        leftControl.zPosition = 100
        leftControl.name = "leftControl"
        addChild(leftControl)
        
       
        let rcontrolSize = rightControl.size
        rightControl.position = CGPoint(x: frame.minX + rcontrolSize.width / 2 + lcontrolSize.width, y: frame.minY + rcontrolSize.height / 2)
        rightControl.zPosition = 100
        rightControl.name = "rightControl"
        addChild(rightControl)
        
        
        let jumpSize = jumpControl.size
        jumpControl.position = CGPoint(x: frame.maxX - jumpSize.width / 2, y: frame.minY + jumpSize.height / 2)
        jumpControl.zPosition = 100
        jumpControl.name = "jumpControl"
        addChild(jumpControl)
        
        
        enemy.position = CGPoint(x: 300, y: 100)
        enemy.zPosition = background.zPosition + 1
        enemy.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: enemy.size.width, height: enemy.size.height))
        enemy.physicsBody?.categoryBitMask = CollisionType.enemy.rawValue
        // Com o que colide
        enemy.physicsBody?.collisionBitMask = CollisionType.player.rawValue
        enemy.physicsBody?.allowsRotation = false
        enemy.name = "enemy"
        addChild(enemy)
        
        
        //Definição do chão (onde ele fica)
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame.inset(by: UIEdgeInsets(top: 10, left: 0, bottom: 30, right: 0)))
        
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchLocal = CGPoint(x: 0, y: 0)
        didJump = false
        jumpYes = false
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {return}
        touchLocal = touch.location(in: self)
    }
    
    override func update(_ currentTime: TimeInterval) {
        
        if rightControl.contains(touchLocal){
            player.run(SKAction.move(to: CGPoint(x: player.position.x + 30, y: player.position.y), duration: 0.1))
        }
        if leftControl.contains(touchLocal){
            player.run(SKAction.move(to: CGPoint(x: player.position.x - 30, y: player.position.y), duration: 0.1))
        }
        if(jumpControl.contains(touchLocal)){
            if(!didJump){
                didJump = true
                jumpYes = true
            }
            
        }

        if (jumpYes == true){
//            var i = 0
//            while i < 20 {
//                if(rightControl.contains(touchLocal)){
//                    persona.physicsBody?.applyImpulse(CGVector(dx: persona.physicsBody?.velocity.dx ?? 0, dy: 50))
//                }
//                else {
//                    persona.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 50))
//                }
//                i = i + 1
//            }
            //jumpYes = false
            if(lastFire + 0.3 < currentTime){
                lastFire = currentTime
                shoot()
            }
            
        }
        
        if(player.position.x >= 350){
            touchLocal = CGPoint(x: 0, y: 0)
            player.position.x = -350
        }
    }
    
    func shoot(){
        guard isPlayerAlive else {return}
        
        let weapon = SKSpriteNode(imageNamed: "pewpew")
        
        weapon.position = CGPoint(x: player.position.x, y: player.position.y)
        weapon.zPosition = background.zPosition + 1
        weapon.physicsBody = SKPhysicsBody(circleOfRadius: weapon.size.height / 3)
        
        weapon.physicsBody?.categoryBitMask = CollisionType.weapon.rawValue
        weapon.physicsBody?.collisionBitMask = CollisionType.ground.rawValue | CollisionType.enemy.rawValue
        weapon.physicsBody?.contactTestBitMask = CollisionType.enemy.rawValue
        weapon.physicsBody?.affectedByGravity = false
        weapon.physicsBody?.mass = 0.1
        weapon.name = "weapon"
        
        addChild(weapon)
        weapon.physicsBody?.applyImpulse(CGVector(dx: 150, dy: 0))
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node else {return}
        guard let nodeB = contact.bodyB.node else {return}
        
        let sortedNodes = [nodeA, nodeB].sorted {$0.name ?? "" <  $1.name ?? ""}
        // Ordem alfabética:
        //Scene (literally)
        //enemy
        //player
        //weapon
        
        let firstNode = sortedNodes[0]
        let secondNode = sortedNodes[1]
        
        if firstNode.children != [] {
            if secondNode.name == "weapon"{
                secondNode.removeFromParent()
            }
        }
        
        if secondNode.name == "player" {
            guard isPlayerAlive else {return}
            
            
            if(firstNode.name == "enemy"){
                gameOver()
                secondNode.removeFromParent()
            }
            
        }
        else if secondNode.name == "weapon" {
            guard isPlayerAlive else {return}
            
            if firstNode.name == "enemy"{
                firstNode.removeFromParent()
                secondNode.removeFromParent()
            }
        }
    }
    
    func gameOver(){
        isPlayerAlive = false
        print("lol dead")
    }
}
