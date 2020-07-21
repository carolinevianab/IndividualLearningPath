//
//  MenuController.swift
//  SkyGame
//
//  Created by Caroline Viana on 13/07/20.
//  Copyright © 2020 Caroline Viana. All rights reserved.
//

import SpriteKit

class MenuController: SKScene {
    let defalts = UserDefaults.standard
    var startgame: SKSpriteNode!
    var startGameEndless: SKSpriteNode!
    var background: SKSpriteNode!
    let decorationPinclet = SKSpriteNode(imageNamed: "Pinclet")
    
    override func didMove(to view: SKView) {
        startgame = (self.childNode(withName: "bntStartNormal") as! SKSpriteNode)
        startGameEndless = (self.childNode(withName: "bntStartEndless") as! SKSpriteNode)
        background = (self.childNode(withName: "background") as! SKSpriteNode)
        
        let wait = SKAction.wait(forDuration: 5)
        let moveGo = SKAction.moveTo(x: -201, duration: 5)
        let moveBack = SKAction.moveTo(x: 201, duration: 5)
        let sequence = SKAction.sequence([wait, moveGo, wait, moveBack])
        background.run(SKAction.repeatForever(sequence))
        
        let emitter = SKEmitterNode(fileNamed: "Starfield")!
        emitter.position = CGPoint(x: 0, y: 0)
        emitter.zPosition = background.zPosition + 1
        addChild(emitter)
        
        setPinclet()
        
    }
    
    func setPinclet(){
         physicsBody = SKPhysicsBody(edgeLoopFrom: frame.inset(by: UIEdgeInsets(top: -200, left: -200, bottom: -200, right: -200)))
        
        decorationPinclet.size = CGSize(width: decorationPinclet.size.width / 1.5, height: decorationPinclet.size.height / 1.5)
        decorationPinclet.position = CGPoint(x: -300, y: -300)
        decorationPinclet.zPosition = background.zPosition + 2
        
        decorationPinclet.physicsBody = SKPhysicsBody(circleOfRadius: decorationPinclet.size.width / 2)
        
        decorationPinclet.physicsBody?.allowsRotation = true
        decorationPinclet.physicsBody?.affectedByGravity = false
        decorationPinclet.physicsBody?.mass = 1
        decorationPinclet.physicsBody?.friction = 0.1
        addChild(decorationPinclet)
        
        let force = SKAction.applyForce(CGVector(dx: 100, dy: 100), duration: 3)
        let rotate = SKAction.rotate(byAngle: .pi/2, duration: 10)
        let forceTwo = SKAction.applyForce(CGVector(dx: -50, dy: 100), duration: 3)
        let sequence = SKAction.sequence([force, rotate, forceTwo])
        decorationPinclet.run(SKAction.repeatForever(sequence))
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {return}
        let touchLocal = touch.location(in: self)
        
        let nodesArray = self.nodes(at: touchLocal)
        
        if nodesArray.first?.name == "bntStartNormal" {
            defalts.set(-1, forKey: Keys.endlessMode)
            let transition = SKTransition.crossFade(withDuration: 0.5)
            let intoGame = GameScene(fileNamed: "GameScene") ?? GameScene(size: self.size)
            self.view?.presentScene(intoGame, transition: transition)
        }
        else if nodesArray.first?.name == "bntStartEndless" {
            defalts.set(-1000, forKey: Keys.endlessMode)
            
            let transition = SKTransition.flipHorizontal(withDuration: 0.5)
            let intoGameEndless = GameScene(fileNamed: "GameScene") ?? GameScene(size: self.size)
            self.view?.presentScene(intoGameEndless, transition: transition)
        }
    }

}
