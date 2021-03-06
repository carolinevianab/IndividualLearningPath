//
//  EndGame.swift
//  SkyGame
//
//  Created by Caroline Viana on 14/07/20.
//  Copyright © 2020 Caroline Viana. All rights reserved.
//

import SpriteKit

class EndGame: SKScene {
    var bntMenu: SKSpriteNode!
    var lblScore: SKLabelNode!
    var gameStatus: SKLabelNode!
    var roomsPassed: SKLabelNode!
    var background: SKSpriteNode!
    var defalts = UserDefaults.standard
    
    let label = SKLabelNode(text: "Back to menu")
    
    override func didMove(to view: SKView) {
        bntMenu = (self.childNode(withName: "bntMenu") as! SKSpriteNode)
        lblScore = (self.childNode(withName: "lblScore") as! SKLabelNode)
        gameStatus = (self.childNode(withName: "lblGameStatus") as! SKLabelNode)
        roomsPassed = (self.childNode(withName: "Rooms") as! SKLabelNode)
        background = (self.childNode(withName: "background") as! SKSpriteNode)
        
        gameStatus.text = defalts.string(forKey: Keys.message) ?? "help"
        lblScore.text = String(defalts.integer(forKey: Keys.score))
        roomsPassed.text = defalts.string(forKey: Keys.rooms)
        
        label.position = CGPoint(x: bntMenu.position.x, y: bntMenu.position.y + 5)
        label.fontSize = 50
        label.fontColor = .black
        label.zPosition = 10
        label.name = "bntMenu"
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        addChild(label)
        
        if gameStatus.text == "You win!" {
            background.position = CGPoint(x: -309, y: -0.5)
        }
        else {
            background.position = CGPoint(x: 309, y: -0.5)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {return}
        let touchLocal = touch.location(in: self)
        
        let nodesArray = self.nodes(at: touchLocal)
        
        if nodesArray.first?.name == "bntMenu" {
            let transition = SKTransition.crossFade(withDuration: 0.5)
            let mainMenu = GameScene(fileNamed: "MenuScene") ?? GameScene(size: self.size)
            self.view?.presentScene(mainMenu, transition: transition)
        }
    }
}
