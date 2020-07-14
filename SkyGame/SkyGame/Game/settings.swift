//
//  settings.swift
//  SkyGame
//
//  Created by Caroline Viana on 14/07/20.
//  Copyright © 2020 Caroline Viana. All rights reserved.
//
import SpriteKit

extension GameScene {
    enum CollisionType: UInt32{
        case ground = 1
        case player = 2
        case enemy = 4
        case weapon = 8
    }
    
    struct EnemyType {
        let name: String
        let weaponImunity: String
        let enemyTexture: SKSpriteNode
        
    }
    
    
    
}


