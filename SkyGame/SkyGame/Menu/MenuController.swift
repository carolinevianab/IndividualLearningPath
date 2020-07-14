//
//  MenuController.swift
//  SkyGame
//
//  Created by Caroline Viana on 13/07/20.
//  Copyright © 2020 Caroline Viana. All rights reserved.
//

import SpriteKit

class MenuController: SKScene {
    var startgame: SKSpriteNode!
    
    override func didMove(to view: SKView) {
        startgame = (self.childNode(withName: "bntStart") as! SKSpriteNode)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {return}
        let touchLocal = touch.location(in: self)
        
        let nodesArray = self.nodes(at: touchLocal)
        
        if nodesArray.first?.name == "bntStart"{
            let transition = SKTransition.flipHorizontal(withDuration: 0.5)
            let bla = GameScene(fileNamed: "GameScene") ?? GameScene(size: self.size)
            self.view?.presentScene(bla, transition: transition)
        }
    }

}
