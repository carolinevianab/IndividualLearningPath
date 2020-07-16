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
    
    override func didMove(to view: SKView) {
        startgame = (self.childNode(withName: "bntStartNormal") as! SKSpriteNode)
        startGameEndless = (self.childNode(withName: "bntStartEndless") as! SKSpriteNode)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {return}
        let touchLocal = touch.location(in: self)
        
        let nodesArray = self.nodes(at: touchLocal)
        
        if nodesArray.first?.name == "bntStartNormal"{
            defalts.set(-1, forKey: Keys.endlessMode)
            let transition = SKTransition.flipHorizontal(withDuration: 0.5)
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
