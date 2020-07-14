//
//  GameScene.swift
//  SkyGame
//
//  Created by Caroline Viana on 23/06/20.
//  Copyright © 2020 Caroline Viana. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    let player = SKSpriteNode(imageNamed: "person")
    let background = SKSpriteNode(imageNamed: "ground")
    let rightControl = SKSpriteNode(imageNamed: "rightArrow")
    let leftControl = SKSpriteNode(imageNamed: "leftArrow")
    let jumpControl = SKSpriteNode(imageNamed: "jump")
    let changeWeaponControl = SKSpriteNode(imageNamed: "jump")
    let ground = SKSpriteNode(imageNamed: "ground2")
    let gameOver = SKSpriteNode(imageNamed: "gameOver")
    let gameWin = SKSpriteNode(imageNamed: "youWin")
    let enemies = ["iEye", "Glixino", "Havyion", "Pinclet"]
    var weaponStatus = true;
    let playerAnimate = [SKTexture(imageNamed: "0"), SKTexture(imageNamed: "1"), SKTexture(imageNamed: "2"), SKTexture(imageNamed: "3"), SKTexture(imageNamed: "4"), SKTexture(imageNamed: "5"), SKTexture(imageNamed: "6"), SKTexture(imageNamed: "7"),SKTexture(imageNamed: "8"), SKTexture(imageNamed: "9"), SKTexture(imageNamed: "10"), SKTexture(imageNamed: "11"),]
    let myScore = SKLabelNode(text: "Score: 0")
    
    var touchLocal: CGPoint = CGPoint(x: 0, y: 0)
    var jumpYes = false
    var didJump = false
    var isPlayerAlive = true
    var lastFire: Double = 0
    var enemyNumber = 0
    var screenCount = -1
    var enemyPerLevel = 0
    var scoreHere = 0
    var timerForWalk: TimeInterval = 0
    var didSet = false
    var helpMen = false
    
    
    // MARK: didMove
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        
        background.position = CGPoint(x: frame.midX, y: frame.midY)
        background.size = frame.size
        background.zPosition = -1
        addChild(background)
        
        
        //Definição do chão (onde ele fica)
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame.inset(by: UIEdgeInsets(top: 10, left: 0, bottom: 30, right: 0)))
        
        
        reloadScreen()
        createScene()
        
        
        myScore.text = "Score: \(scoreHere)"
        myScore.position = CGPoint(x: frame.minX + 10, y: frame.maxY - 60)
        myScore.horizontalAlignmentMode = .left
        myScore.zPosition = 100
        addChild(myScore)
    }
    
    // MARK: touchesEnded
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchLocal = CGPoint(x: 0, y: 0)
        didJump = false
        player.removeAllActions()
        player.texture = SKTexture(imageNamed: "0")
        jumpYes = false
        helpMen = false
        
    }
    
    // MARK: touchesBegan
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {return}
        touchLocal = touch.location(in: self)
    }
    
    
    // MARK: update
    override func update(_ currentTime: TimeInterval) {
        myScore.text = "Score: \(scoreHere)"
        
        if rightControl.contains(touchLocal){
            if(!didSet){
                timerForWalk = currentTime
                didSet = true
            }
            if timerForWalk <= currentTime{
            player.run(SKAction.animate(with: playerAnimate, timePerFrame: 0.1))
                timerForWalk = currentTime + 1.2
            }
            player.run(SKAction.move(to: CGPoint(x: player.position.x + 30, y: player.position.y), duration: 0.1))
        }
        
        if leftControl.contains(touchLocal){
            let playerAnimateBackwards = playerAnimate.reversed() as [SKTexture]
            if(!didSet){
                timerForWalk = currentTime
                didSet = true
            }
            if timerForWalk <= currentTime{
            player.run(SKAction.animate(with: playerAnimateBackwards, timePerFrame: 0.1))
                timerForWalk = currentTime + 1.2
            }
            player.run(SKAction.move(to: CGPoint(x: player.position.x - 30, y: player.position.y), duration: 0.1))
        }
        
        if(jumpControl.contains(touchLocal)){
            if(lastFire + 0.3 < currentTime){
                lastFire = currentTime
                shoot()
            }
        }
        
        if(changeWeaponControl.contains(touchLocal)){
            if(!helpMen){
                weaponStatus.toggle()
                if(weaponStatus){
                    changeWeaponControl.color = UIColor(red: 255, green: 0, blue: 0, alpha: 1)
                    changeWeaponControl.colorBlendFactor = 0.9
                }
                else{
                    changeWeaponControl.color = UIColor(red: 0, green: 0, blue: 255, alpha: 1)
                    changeWeaponControl.colorBlendFactor = 0.9
                }
                print("weaponStatus: \(weaponStatus)")
                helpMen = true
            }
            
        }
         
        if(player.position.x >= 350){
            touchLocal = CGPoint(x: 0, y: 0)
            player.removeAllActions()
            player.position.x = -350
            player.texture = SKTexture(imageNamed: "0")
        }
        
        if player.position.x == -350{
            player.position.x = -349
            reloadScreen()
        }
        
        if(isPlayerAlive && screenCount == 10){
            youWin()
        }
        
        guard let bla = self.childNode(withName: "enemy") else {return}
        
        if player.position.x  >= bla.position.x - 200 {
            guard isPlayerAlive else {return}
            isPlayerAlive = false
            gameOverDead()
            player.removeFromParent()
        }
    }
    
    // MARK: CreateScene
    func createScene(){
        player.size = CGSize(width: player.size.width / 1.5, height: player.size.height / 1.5)
         player.position = CGPoint(x: 0, y: 10)
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
        
        changeWeaponControl.size = CGSize(width: changeWeaponControl.size.width / 2, height: changeWeaponControl.size.height / 2)
        changeWeaponControl.position = CGPoint(x: jumpControl.position.x - jumpControl.size.width, y: jumpControl.position.y)
        changeWeaponControl.zPosition = 100
        changeWeaponControl.color = UIColor(red: 255, green: 0, blue: 0, alpha: 1)
        changeWeaponControl.colorBlendFactor = 0.9
        addChild(changeWeaponControl)
    }

    // MARK: ReloadScreen
    func reloadScreen(){
        if(enemyNumber == 0){
            screenCount += 1
            if(screenCount == 1 || screenCount == 4 || screenCount == 7){
                enemyPerLevel += 1
            }
            makeEnemy()
        }
        
    }
    
    // MARK: MakeEnemy
    func makeEnemy(){
        while(enemyNumber < enemyPerLevel){
            let choice = enemies.randomElement() ?? "iEye"
            let enemy = SKSpriteNode(imageNamed: choice)
            
            let m = Int.random(in: -100 ... 300)
            
            enemy.position = CGPoint(x: m, y: 0)
            enemy.zPosition = background.zPosition + 1
            enemy.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: enemy.size.width, height: enemy.size.height))
            enemy.physicsBody?.categoryBitMask = CollisionType.enemy.rawValue
            enemy.physicsBody?.collisionBitMask = CollisionType.player.rawValue
            enemy.physicsBody?.allowsRotation = false
            enemy.name = choice
            addChild(enemy)
            
            enemyNumber += 1
            
        }
    }
    
    // MARK: Shoot
    func shoot(){
        guard isPlayerAlive else {return}
        
        let weapon = SKSpriteNode(imageNamed: "pewpew")
        
        weapon.position = CGPoint(x: player.position.x, y: player.position.y - 20)
        weapon.zPosition = background.zPosition + 1
        //weapon.size = CGSize(width: weapon.size.width / 2, height: weapon.size.height / 2)
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
    
    // MARK: didBegin
    func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node else {return}
        guard let nodeB = contact.bodyB.node else {return}
        
        let sortedNodes = [nodeA, nodeB].sorted {$0.name ?? "" <  $1.name ?? ""}
        // Ordem alfabética:
        //Scene (literally)
        //Glixino
        //Havyion
        //iEye
        //Pinclet
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
            
            if firstNode.name == "Glixino" || firstNode.name == "Havyion" || firstNode.name == "iEye" || firstNode.name == "Pinclet" {
                gameOverDead()
                secondNode.removeFromParent()
            }
            
        }
        else if secondNode.name == "weapon" {
            guard isPlayerAlive else {return}
            
            if firstNode.name == "enemy"{
                firstNode.removeFromParent()
                secondNode.removeFromParent()
                enemyNumber -= 1
            }
            
            switch firstNode.name {
            case "Glixino":
                scoreHere += 10
                firstNode.removeFromParent()
                secondNode.removeFromParent()
                enemyNumber -= 1
                break;
            case "Havyion":
                scoreHere += 10
                firstNode.removeFromParent()
                secondNode.removeFromParent()
                enemyNumber -= 1
                break;
            case "iEye":
                if weaponStatus == true {
                    scoreHere += 10
                }
                scoreHere += 10
                firstNode.removeFromParent()
                secondNode.removeFromParent()
                enemyNumber -= 1
                break;
            case "Pinclet":
                if weaponStatus == false{
                    scoreHere += 10
                }
                scoreHere += 10
                firstNode.removeFromParent()
                secondNode.removeFromParent()
                enemyNumber -= 1
                break;
            default:
                secondNode.removeFromParent()
                print("aaaaa")
                break;
            }
        }
    }
    
    // MARK: GameOver
    func gameOverDead(){
        isPlayerAlive = false
        print("lol dead")
        self.removeAllChildren()
        
        endGame(endStatus: "Game Over!")

    }
    var i = 0
    
    // MARK: youWin
    func youWin(){
        
        if(i == 0){
           endGame(endStatus: "You win!")
            i+=1
        }
        
    }
    
    // MARK: EndGame
    func endGame(endStatus: String){
        self.removeAllChildren()
        let ble = EndGame()
        ble.defalts.set(endStatus, forKey: "Message")
        ble.defalts.set(scoreHere, forKey: "Score")
        
        let transition = SKTransition.flipHorizontal(withDuration: 0.5)
        let bla = GameScene(fileNamed: "endGameScene") ?? GameScene(size: self.size)
        self.view?.presentScene(bla, transition: transition)
    }
}
