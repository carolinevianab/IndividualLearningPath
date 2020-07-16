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
        case plant = 16
    }
    
    enum zPositions: CGFloat {
        case background = 0
        case gameAreabutBehind = 2
        case gameArea = 4
        case controls = 6
        case labels = 8
    }
    
}

extension SKScene {
    struct Keys {
        static let endlessMode = "EndlessMode"
        static let message =  "Message"
        static let score = "Score"
        static let rooms = "Rooms"
    }
}



