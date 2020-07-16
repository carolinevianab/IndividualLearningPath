//
//  GameScene.swift
//  SkyGame
//
//  Created by Caroline Viana on 23/06/20.
//  Copyright © 2020 Caroline Viana. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    let defalts = UserDefaults.standard
    
    // Sprites
    var backgroundNow = SKSpriteNode(imageNamed: "ground1")
    let player = SKSpriteNode(imageNamed: "person")
    let rightControl = SKSpriteNode(imageNamed: "rightArrow")
    let leftControl = SKSpriteNode(imageNamed: "leftArrow")
    let shootControl = SKSpriteNode(imageNamed: "shoot")
    let changeWeaponControl = SKSpriteNode(imageNamed: "shoot")
    
    // Labels
    let myScore = SKLabelNode(text: "Score: 0")
    let roomNumber = SKLabelNode(text: "Room: 0")
    let ammoF = SKLabelNode(text: "0")
    let ammoI = SKLabelNode(text: "0")
    
    // Arrays
    let backgrounds = ["ground1", "ground2", "ground3"]
    let enemies = ["iEye", "Glixino", "Havyion", "Pinclet"]
    let plants = ["vatra", "ayezi"]
    let playerAnimate = [SKTexture(imageNamed: "0"), SKTexture(imageNamed: "1"), SKTexture(imageNamed: "2"), SKTexture(imageNamed: "3"), SKTexture(imageNamed: "4"), SKTexture(imageNamed: "5"), SKTexture(imageNamed: "6"), SKTexture(imageNamed: "7"),SKTexture(imageNamed: "8"), SKTexture(imageNamed: "9"), SKTexture(imageNamed: "10"), SKTexture(imageNamed: "11"),]

    // booleans
    var weaponStatus = true // fire or ice
    var isPlayerAlive = true // player alive or dead
    var didSet = false // For walking animation
    var didChange = false // for changing weapon
    
    // Other variables
    var touchLocal: CGPoint = CGPoint(x: 0, y: 0) // where were touched
    var lastFire: Double = 0 // last time the gun fired
    var timerForWalk: TimeInterval = 0 // For walking animation
    var enemyNumber = 0 // how many enemies are left
    var enemyPerLevel = 0 // how many enemies each level will have
    var screenCount: Int = 0 // how many screens player passed throught
    var scoreHere = 0 //Score
    var fireAmmo = 2
    var iceAmmo = 2
    
    // MARK: didMove
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        
        generateBackground()
        addChild(backgroundNow)
        
        //Definição do chão (onde ele fica)
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame.inset(by: UIEdgeInsets(top: 10, left: 0, bottom: 30, right: 0)))
        
        screenCount = defalts.integer(forKey: Keys.endlessMode)
        
        createScene()
        
        if(defalts.integer(forKey: Keys.endlessMode) == -1000){
            enemyPerLevel = 1
        }
        
        reloadScreen()
    }
    
    // MARK: touchesEnded
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchLocal = CGPoint(x: 0, y: 0)
        player.removeAllActions()
        player.texture = SKTexture(imageNamed: "0")
        didChange = false
        
    }
    
    // MARK: touchesBegan
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {return}
        touchLocal = touch.location(in: self)
    }
    
    // MARK: update
    override func update(_ currentTime: TimeInterval) {
        myScore.text = "Score: \(scoreHere)"
        ammoF.text = "\(fireAmmo)"
        ammoI.text = "\(iceAmmo)"
        
        if(defalts.integer(forKey: Keys.endlessMode) == -1000){
            roomNumber.text = "Room \(screenCount + 1000)"
        }
        else{
            roomNumber.text = "Room \(screenCount)"
        }
        
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
        
        if(shootControl.contains(touchLocal)){
            if(lastFire + 0.3 < currentTime){
                lastFire = currentTime
                shoot()
            }
        }
        
        if(changeWeaponControl.contains(touchLocal)){
            if(!didChange){
                weaponStatus.toggle()
                if(weaponStatus){
                    changeWeaponControl.color = .systemRed
                    changeWeaponControl.colorBlendFactor = 0.9
                }
                else{
                    changeWeaponControl.color = .systemBlue
                    changeWeaponControl.colorBlendFactor = 0.9
                }
                didChange = true
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
            generateBackground()
        }
        
        if(isPlayerAlive && screenCount == 11){
            youWin()
        }
        
    }
    
    
    // MARK: GenerateBackground
    func generateBackground(){
        let choice = backgrounds.randomElement()
        
        if backgroundNow.name != choice {
            backgroundNow.texture = SKTexture(imageNamed: choice ?? "ground1")
            backgroundNow.position = CGPoint(x: frame.midX, y: frame.midY)
            backgroundNow.size = frame.size
            backgroundNow.zPosition = zPositions.background.rawValue
            backgroundNow.name = choice
            generatePlants()
        }
        else{
            generateBackground()
        }
        
    }
    
    // MARK: GeneratePlants
    func generatePlants(){
        let numberOfPlants = Int.random(in: 1...3)
        var counter = 0
        
        while(counter < numberOfPlants){
            let randomPosition = Int.random(in: -200...200)
            let plant = plants.randomElement()!
            let plantSprite = SKSpriteNode(imageNamed: plant)
            plantSprite.position = CGPoint(x: randomPosition, y: 0)
            plantSprite.zPosition = zPositions.gameAreabutBehind.rawValue
            plantSprite.name = plant
            
            plantSprite.physicsBody = SKPhysicsBody(circleOfRadius: plantSprite.size.height / 2)
            plantSprite.physicsBody?.affectedByGravity = false
            plantSprite.physicsBody?.categoryBitMask = CollisionType.plant.rawValue
            plantSprite.physicsBody?.collisionBitMask = CollisionType.ground.rawValue
            plantSprite.physicsBody?.contactTestBitMask = CollisionType.player.rawValue
            
            addChild(plantSprite)
            counter += 1
        }
    }
    
    // MARK: CreateScene
    func createScene(){
        player.size = CGSize(width: player.size.width / 1.5, height: player.size.height / 1.5)
        
        if(defalts.integer(forKey: Keys.endlessMode) == -1000){
            player.position = CGPoint(x: -350, y: 10)
        }
        else{
            player.position = CGPoint(x: 0, y: 10)
        }
        
        /// Player
        player.zPosition = zPositions.gameArea.rawValue
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
         
        /// Left control
        leftControl.position = CGPoint(x: frame.minX + leftControl.size.width / 2, y: frame.minY + leftControl.size.height / 2)
        leftControl.zPosition = zPositions.controls.rawValue
        leftControl.name = "leftControl"
        addChild(leftControl)
        
        rightControl.position = CGPoint(x: frame.minX + rightControl.size.width / 2 + leftControl.size.width, y: frame.minY + rightControl.size.height / 2)
        rightControl.zPosition = zPositions.controls.rawValue
        rightControl.name = "rightControl"
        addChild(rightControl)
         
        shootControl.position = CGPoint(x: frame.maxX - shootControl.size.width / 2, y: frame.minY + shootControl.size.height / 2)
        shootControl.zPosition = zPositions.controls.rawValue
        shootControl.name = "shootControl"
        addChild(shootControl)
        
        changeWeaponControl.size = CGSize(width: changeWeaponControl.size.width / 1.5, height: changeWeaponControl.size.height / 1.5)
        changeWeaponControl.position = CGPoint(x: shootControl.position.x - shootControl.size.width, y: shootControl.position.y)
        changeWeaponControl.zPosition = zPositions.controls.rawValue
        changeWeaponControl.color = UIColor(red: 255, green: 0, blue: 0, alpha: 1)
        changeWeaponControl.colorBlendFactor = 0.9
        changeWeaponControl.name = "changeWeaponControl"
        addChild(changeWeaponControl)
        
        myScore.text = "Score: \(scoreHere)"
        myScore.position = CGPoint(x: frame.minX + 10, y: frame.maxY - 60)
        myScore.horizontalAlignmentMode = .left
        myScore.zPosition = zPositions.labels.rawValue
        myScore.name = "Score"
        addChild(myScore)
        
        roomNumber.text = "Room \(screenCount)"
        roomNumber.position = CGPoint(x: frame.maxX - 10, y: frame.maxY - 60)
        roomNumber.zPosition = zPositions.labels.rawValue
        roomNumber.horizontalAlignmentMode = .right
        roomNumber.name = "RoomNumber"
        addChild(roomNumber)
        
        ammoF.text = "\(fireAmmo)"
        ammoF.fontColor = .systemRed
        ammoF.fontName = "Helvetica Neue Bold"
        ammoF.fontSize = 30
        ammoF.position = CGPoint(x: changeWeaponControl.position.x + 40, y: changeWeaponControl.position.y + 5)
        ammoF.zPosition = zPositions.labels.rawValue
        addChild(ammoF)
        
        ammoI.text = "\(iceAmmo)"
        ammoI.fontColor = .systemBlue
        ammoI.fontName = "Helvetica Neue Bold"
        ammoI.fontSize = 30
        ammoI.position = CGPoint(x: changeWeaponControl.position.x + 40, y: changeWeaponControl.position.y - 25)
        ammoI.zPosition = zPositions.labels.rawValue
        addChild(ammoI)
    }

    // MARK: ReloadScreen
    func reloadScreen(){
        while childNode(withName: "vatra") != nil || childNode(withName: "ayezi") != nil {
            childNode(withName: "vatra")?.removeFromParent()
            childNode(withName: "ayezi")?.removeFromParent()
        }
        if(enemyNumber == 0){
            screenCount += 1
            if(defalts.integer(forKey: Keys.endlessMode) == -1000){
                makeEnemy()
                enemyPerLevel = Int.random(in: 1...5)
            }
            else{
                if(screenCount == 1 || screenCount == 4 || screenCount == 7){
                    enemyPerLevel += 1
                }
                makeEnemy()
            }
            
        }
        
    }
    
    // MARK: MakeEnemy
    func makeEnemy(){
        while(enemyNumber < enemyPerLevel){
            let choice = enemies.randomElement() ?? "iEye"
            let enemy = SKSpriteNode(imageNamed: choice)
            
            let enemyPosition = Int.random(in: -100 ... 300)
            
            if choice == "Pinclet"{
                enemy.size = CGSize(width: enemy.size.width / 1.5, height: enemy.size.height / 1.5)
            }
            
            enemy.position = CGPoint(x: enemyPosition, y: 0)
            enemy.zPosition = zPositions.gameArea.rawValue
            enemy.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: enemy.size.width, height: enemy.size.height))
            enemy.physicsBody?.categoryBitMask = CollisionType.enemy.rawValue
            enemy.physicsBody?.collisionBitMask = CollisionType.player.rawValue
            enemy.physicsBody?.allowsRotation = false
            enemy.name = choice
            enemy.physicsBody?.mass = 1
            enemy.physicsBody?.friction = 0.1
            if(choice == "Havyion"){
                enemy.physicsBody?.affectedByGravity = false
            }
            addChild(enemy)
            
            enemyNumber += 1
            
            let movement: SKAction!
            let left: SKAction!
            let right: SKAction!
            switch choice {
            case "Glixino":
                movement = SKAction.applyImpulse(CGVector(dx: 500, dy: 0), duration: 3)
                enemy.run(SKAction.repeatForever(movement))
                break;
            case "Havyion":
                movement = SKAction.applyImpulse(CGVector(dx: -300, dy: 0), duration: 5)
                enemy.run(SKAction.repeatForever(movement))
                break;
            case "iEye":
                left = SKAction.applyImpulse(CGVector(dx: 400, dy: 500), duration: 1)
                right = SKAction.applyImpulse(CGVector(dx: -300, dy: 500), duration: 1)
                movement = SKAction.sequence([left, left, right])
                enemy.run(SKAction.repeatForever(movement))
                break;
            case "Pinclet":
                movement = SKAction.applyImpulse(CGVector(dx: 300, dy: 500), duration: 2)
               enemy.run(SKAction.repeatForever(movement))
                break;
            default:
                break;
            }
            
        }
    }
    
    // MARK: Shoot
    func shoot(){
        guard isPlayerAlive else {return}
        
        if weaponStatus && fireAmmo == 0 {return}
        if !weaponStatus && iceAmmo == 0 {return}
        
        let weapon = SKSpriteNode(imageNamed: "pewpew")
        
        weapon.position = CGPoint(x: player.position.x, y: player.position.y - 20)
        weapon.zPosition = zPositions.gameArea.rawValue
        weapon.physicsBody = SKPhysicsBody(circleOfRadius: weapon.size.height / 3)
        
        let emitter: SKEmitterNode!
        
        if(weaponStatus){
            weapon.color = .systemRed
            weapon.colorBlendFactor = 0.9
            emitter = SKEmitterNode(fileNamed: "fireball")
            fireAmmo -= 1
        }
        else{
            weapon.color = .systemBlue
            weapon.colorBlendFactor = 0.9
            emitter = SKEmitterNode(fileNamed: "iceball")
            iceAmmo -= 1
        }
        
        weapon.physicsBody?.categoryBitMask = CollisionType.weapon.rawValue
        weapon.physicsBody?.collisionBitMask = CollisionType.ground.rawValue | CollisionType.enemy.rawValue
        weapon.physicsBody?.contactTestBitMask = CollisionType.enemy.rawValue
        weapon.physicsBody?.affectedByGravity = false
        weapon.physicsBody?.mass = 0.1
        weapon.name = "weapon"
        
        addChild(weapon)
        weapon.physicsBody?.applyImpulse(CGVector(dx: 150, dy: 0))
        
//        let emitter = SKEmitterNode(fileNamed: "fireball")!
        emitter.zPosition = zPositions.gameArea.rawValue
        emitter.position = CGPoint(x: 0, y: 0)
        emitter.name = "emitter"
        //addChild(emitter)
        weapon.addChild(emitter)
        
        
        let wait = SKAction.wait(forDuration: 0.1)
        //let waitEm = SKAction.wait(forDuration: 1)
        let remove = SKAction.removeFromParent()
        weapon.run(SKAction.sequence([wait, remove]))
        //emitter.run(SKAction.sequence([waitEm, remove]))
    }
    
    
    // MARK: didBegin
    func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node else {return}
        guard let nodeB = contact.bodyB.node else {return}
        
        let sortedNodes = [nodeA, nodeB].sorted {$0.name ?? "" <  $1.name ?? ""}
        // Ordem alfabética:
        //Scene (literally)
        //ayezi
        //Glixino
        //Havyion
        //iEye
        //Pinclet
        //player
        //vatra
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
            
            if firstNode.name == "ayezi" && iceAmmo < 3 {
                firstNode.removeFromParent()
                iceAmmo += 1
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
                firstNode.removeAllActions()
                firstNode.removeFromParent()
                secondNode.removeFromParent()
                enemyNumber -= 1
                break;
            case "Havyion":
                scoreHere += 10
                firstNode.removeAllActions()
                firstNode.removeFromParent()
                secondNode.removeFromParent()
                enemyNumber -= 1
                break;
            case "iEye":
                if weaponStatus == true {
                    scoreHere += 10
                }
                scoreHere += 10
                firstNode.removeAllActions()
                firstNode.removeFromParent()
                secondNode.removeFromParent()
                enemyNumber -= 1
                break;
            case "Pinclet":
                if weaponStatus == false{
                    scoreHere += 10
                }
                firstNode.removeAllActions()
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
        else if firstNode.name == "player"{
            if secondNode.name == "vatra" && fireAmmo < 3{
                secondNode.removeFromParent()
                fireAmmo += 1
            }
        }
    }
    
    // MARK: GameOver
    func gameOverDead(){
        isPlayerAlive = false
        endGame(endStatus: "Game Over!")

    }
    
    // MARK: youWin
    func youWin(){
        endGame(endStatus: "You win!")
        
    }
    
    // MARK: EndGame
    func endGame(endStatus: String){
        self.removeAllChildren()
        defalts.set(endStatus, forKey: Keys.message)
        defalts.set(scoreHere, forKey: Keys.score)
        
        if defalts.integer(forKey: Keys.endlessMode) == -1000{
            defalts.set("Rooms: \(screenCount + 1000)", forKey: Keys.rooms)
        }
        else{
            defalts.set("Rooms: \(screenCount)/10", forKey: Keys.rooms)
        }
        
        let transition = SKTransition.flipHorizontal(withDuration: 0.5)
        let endScene = GameScene(fileNamed: "endGameScene") ?? GameScene(size: self.size)
        self.view?.presentScene(endScene, transition: transition)
    }
}
