//
//  GameScene.swift
//  Project Space Monkey
//
//  Created by Binh Le on 12/30/16.
//  Copyright © 2016 Binh Le. All rights reserved.
//

import AVFoundation
import SpriteKit
import GameKit

struct PhysicsCategory {
    
    static let None      : UInt32 = 0
    static let All       : UInt32 = UInt32.max
    static let TempRock  : UInt32 = 0b1       // 1
    static let Rock      : UInt32 = 0b10      // 2
    static let Laser     : UInt32 = 0b11      // 3
    static let Char      : UInt32 = 0b100     // 4
    static let Screen    : UInt32 = 0b101     // 5
}

class GameScene: SKScene, SKPhysicsContactDelegate {

    
    let character = SKSpriteNode(imageNamed: "spacemonkey")
    var count: NSInteger = 0
    var start = false
    var dead = false
    var xVelocity: CGFloat = 0
    var shoot = false
    
    //background music
    let backgroundMusic = SKAudioNode(fileNamed: "funky.mp3")
    var backgroundMusicPlayer = AVAudioPlayer()
    var musicSwitch = SKSpriteNode()
    
    //animations
    var audioPlayer = AVAudioPlayer()
    var sfxShoot: SystemSoundID = 0
    var sfxSplat: SystemSoundID = 0
    var sfxMove: SystemSoundID = 0
    var sfxBump: SystemSoundID = 0
    var bgmusic: SystemSoundID = 0
    var muted =  false
    
    //game vars
    var highScore = 0
    var roundScore = 0

    
    weak var viewController: GameViewController!
    
    override func didMove(to view: SKView) {
        
        //HIGH SCORE FROM MEMORY//
        let highScoreDefault = UserDefaults.standard
        if(highScoreDefault.value(forKey: "highScore") != nil) {
            highScore = highScoreDefault.value(forKey: "highScore") as! NSInteger!
        }
        let roundScoreDefault = UserDefaults.standard
        if(roundScoreDefault.value(forKey: "roundScore") != nil) {
            roundScore = roundScoreDefault.value(forKey: "roundScore") as! NSInteger!
        }
        let muteDefault = UserDefaults.standard
        if (muteDefault.value(forKey: "muted") != nil) {
            muted = muteDefault.value(forKey: "muted") as! Bool!
        }

        let dust = SKSpriteNode(imageNamed: "spacedust")
        dust.position = CGPoint(x: 0, y: 0)
        dust.size = self.frame.size
        dust.zPosition = -1
        self.addChild(dust)
        
        let dustDestination = CGPoint(x: 0, y: -self.frame.size.height)
        let dustAction = SKAction.move(to: dustDestination, duration: 5.00)
        let dustActionDone = SKAction.removeFromParent()
        dust.run(SKAction.sequence([dustAction, dustActionDone]))
        self.initScroll()
        
        character.physicsBody = SKPhysicsBody(rectangleOf: character.size)
        character.physicsBody!.affectedByGravity = false
        character.physicsBody!.isDynamic = true
        character.physicsBody?.categoryBitMask = PhysicsCategory.Char
        character.physicsBody?.contactTestBitMask = PhysicsCategory.TempRock | PhysicsCategory.Rock
        character.physicsBody?.collisionBitMask = PhysicsCategory.Screen
        character.physicsBody!.angularVelocity = 0
        character.physicsBody!.allowsRotation = false
        
        
        let borderBody = SKPhysicsBody(edgeLoopFrom: frame)
        borderBody.categoryBitMask = PhysicsCategory.Screen
        borderBody.contactTestBitMask  = PhysicsCategory.None
        borderBody.collisionBitMask = PhysicsCategory.Screen
        self.physicsBody = borderBody
        
        character.physicsBody?.usesPreciseCollisionDetection = true
        character.position = CGPoint(x: 0, y: 0 - size.height * 0.25)
        character.zPosition = 5
        
        start = true
        setUpGame()
    }
    
    //Starts Game
    func setUpGame(){
        
        print("mute value: \(muted)")
        
        // LABELS
        musicSwitch = childNode(withName: "Music") as! SKSpriteNode
        if muted == false {
            musicSwitch.texture = SKTexture(imageNamed: "unmute")
            playBackgroundMusic()
        } else {
            if muted == true {
                musicSwitch.texture = SKTexture(imageNamed: "mute")
            }
        }
        
        //sounds
        let sfxShoot = URL(fileURLWithPath: Bundle.main.path(forResource: "gun", ofType: "mp3")!)
        let sfxSplat = URL(fileURLWithPath: Bundle.main.path(forResource: "splat", ofType: "wav")!)
        let sfxMove = URL(fileURLWithPath: Bundle.main.path(forResource: "swoosh", ofType: "wav")!)
        let sfxBump = URL(fileURLWithPath: Bundle.main.path(forResource: "bump", ofType: "wav")!)
        let bgmusic = URL(fileURLWithPath: Bundle.main.path(forResource: "funky", ofType: "mp3")!)
        AudioServicesCreateSystemSoundID(bgmusic as CFURL, &self.bgmusic)
        AudioServicesCreateSystemSoundID(sfxShoot as CFURL, &self.sfxShoot)
        AudioServicesCreateSystemSoundID(sfxSplat as CFURL, &self.sfxSplat)
        AudioServicesCreateSystemSoundID(sfxMove as CFURL, &self.sfxMove)
        AudioServicesCreateSystemSoundID(sfxBump as CFURL, &self.sfxBump)
        
        self.addChild(character)
        if (randRange(1,upper:2) == 1){
            xVelocity = -200
        }
        else{
            xVelocity = 200
        }
        
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        physicsWorld.contactDelegate = self
        self.shoot = true
        
        delay(1.5){
            self.addRocks()
        }
        let label = SKLabelNode(fontNamed: "MarkerFelt-Thin")
        label.position = CGPoint(x: 0, y: frame.maxY - 100)
        label.setScale(3.0)
        label.text = String(0)
        label.zPosition = 50
        addChild(label)
        
        delay(5.25){
            self.count += 100
            //self.leaderboard(self.count)
            label.removeFromParent()
            self.initHUD()
        }
    }
    
    //Sets Score And Increments
    func initHUD() {
        print("score increase")
        let label_score = SKLabelNode(fontNamed:"MarkerFelt-Thin")
        label_score.setScale(3.0)
        label_score.position = CGPoint(x: 0, y: frame.maxY - 100)
        label_score.text = String(count)
        label_score.zPosition = 50
        addChild(label_score)
        
        delay(1.5){
            label_score.removeFromParent()
            self.count += 100
            self.initHUD()
        }
    }
    
    //Scrolls Background
    func initScroll(){
        
        let dust = SKSpriteNode(imageNamed: "spacedust")
        dust.position = CGPoint(x: 0, y: self.frame.size.height)
        dust.size = self.frame.size
        self.addChild(dust)
        dust.zPosition = -1
        let dustDestination = CGPoint(x: 0, y: -self.frame.size.height)
        
        let dustAction = SKAction.move(to: dustDestination, duration: 10.00)
        let dustActionDone = SKAction.removeFromParent()
        dust.run(SKAction.sequence([dustAction, dustActionDone]))
        
        delay(4.75){
            self.initScroll()
        }
    }
    
    //Shoots Laser From Character
    func fireLaser(){
        
        if (self.dead == false && self.shoot == true){
            if muted == false {
                AudioServicesPlaySystemSound(self.sfxShoot)
            }
            let laser = SKSpriteNode(imageNamed: "Banana")
            laser.position = CGPoint(x:character.position.x, y: character.position.y + 120)
            self.addChild(laser)
            
            laser.physicsBody = SKPhysicsBody(circleOfRadius: laser.size.width/2 + 4)
            laser.physicsBody?.isDynamic = true
            laser.physicsBody?.categoryBitMask = PhysicsCategory.Laser
            laser.physicsBody?.contactTestBitMask = PhysicsCategory.TempRock | PhysicsCategory.Rock
            laser.physicsBody?.collisionBitMask = PhysicsCategory.None
            laser.physicsBody?.usesPreciseCollisionDetection = true
            
            let laserDestination = CGPoint(x: character.position.x, y: self.size.height)
            let actionMove = SKAction.move(to: laserDestination, duration: 1.5)
            let actionMoveDone = SKAction.removeFromParent()
            laser.run(SKAction.sequence([actionMove, actionMoveDone]))
        }
    }
    
    //Uses Touches On Button To Move Sprite Left And Right
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch in touches {
            let location = touch.location(in: self)
            
            if atPoint(location).name == "Music" {
                if muted == false {
                    musicSwitch.texture = SKTexture(imageNamed: "mute")
                    muted = true
                    let muteDefault = UserDefaults.standard
                    muteDefault.setValue(muted, forKey: "muted")
                    muteDefault.synchronize()
                    print(muted)
                    print("turning off music")
                    backgroundMusicPlayer.stop()
                }
                else{
                    if muted == true {
                        musicSwitch.texture = SKTexture(imageNamed: "unmute")
                        muted = false
                        let muteDefault = UserDefaults.standard
                        muteDefault.setValue(muted, forKey: "muted")
                        muteDefault.synchronize()
                        print(muted)
                        print("playing music")
                        playBackgroundMusic()
                    }
                }
            }
        
            if atPoint(location).name == "Left" {
                xVelocity = -380
                print("move left")
                if muted == false {
                    AudioServicesPlaySystemSound(self.sfxMove)
                    print("left move")
                }
            }
            
            if atPoint(location).name == "Right" {
                xVelocity = 380
                print("move right")
                if muted == false {
                    AudioServicesPlaySystemSound(self.sfxMove)
                }
            }
            
            if atPoint(location).name == "Fire" {
                print("fire banana")
                fireLaser()
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?)  {
        
        if (xVelocity>0){
            xVelocity = 200
        }
        else{
            xVelocity = -200
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        
        let rate: CGFloat = 0.5; //Controls rate of motion. 1.0 instantaneous, 0.0 none.
        
        let relativeVelocity: CGVector = CGVector(dx:xVelocity-character.physicsBody!.velocity.dx, dy:0);
        character.physicsBody!.velocity=CGVector(dx:character.physicsBody!.velocity.dx+relativeVelocity.dx*rate, dy:0);
    }
    
    //Spawns Rocks
    func addRocks(){
        
        let missRock = randRange(3,upper: 8)
        var count: CGFloat = 1.0
        
        while (count <= 10){
            let countInt: Int = Int(count)
            if (missRock == countInt || missRock == countInt-1 || missRock == countInt+1){
                let temp = randRange(1, upper: 2)
                if (temp == 1 && missRock == countInt){
                    tempRock(count)
                }
            }
            else{
                rock(count)
            }
            count += 1
        }
        delay(1.5){
            self.addRocks()
        }
    }
    
    func rock(_ count: CGFloat){
        
        let rock = SKSpriteNode(imageNamed: "rock")
        rock.position = CGPoint(x: size.width/10 * count - 32 - size.width/2, y: size.height/2 + 100)
        self.addChild(rock)
        
        rock.physicsBody = SKPhysicsBody(circleOfRadius: rock.size.width/2-25) // 1
        rock.physicsBody?.isDynamic = true // 2
        rock.physicsBody?.categoryBitMask = PhysicsCategory.Rock // 3
        rock.physicsBody?.contactTestBitMask = PhysicsCategory.Laser | PhysicsCategory.Char // 4
        rock.physicsBody?.collisionBitMask = PhysicsCategory.None // 5
        rock.physicsBody?.usesPreciseCollisionDetection = true
        
        let rockDestination = CGPoint(x: size.width/10 * count - 32 - size.width/2, y: -size.height/2 - 100)
        let rockMove = SKAction.move(to: rockDestination, duration: 4.5)
        let rockMoveDone = SKAction.removeFromParent()
        rock.run(SKAction.sequence([rockMove, rockMoveDone]))
    }
    
    func tempRock(_ count: CGFloat){
        
        let tRock = SKSpriteNode(imageNamed: "Alien")
        tRock.position = CGPoint(x: size.width/10 * count - 32 - size.width/2, y: size.height/2+100)
        self.addChild(tRock)
        
        tRock.physicsBody = SKPhysicsBody(circleOfRadius: tRock.size.width/2 - 19) // 1
        tRock.physicsBody?.isDynamic = true // 2
        tRock.physicsBody?.categoryBitMask = PhysicsCategory.TempRock // 3
        tRock.physicsBody?.contactTestBitMask = PhysicsCategory.Laser | PhysicsCategory.Char // 4
        tRock.physicsBody?.collisionBitMask = PhysicsCategory.None // 5
        tRock.physicsBody?.usesPreciseCollisionDetection = true
        
        let rockDestination = CGPoint(x: size.width/10 * count - 32 - size.width/2, y: -size.height/2-100)
        let rockMove = SKAction.move(to: rockDestination, duration: 4.5)
        let rockMoveDone = SKAction.removeFromParent()
        tRock.run(SKAction.sequence([rockMove, rockMoveDone]))
    }
    
    func randRange (_ lower: Int , upper: Int) -> Int {

        return lower + Int(arc4random_uniform(UInt32(upper - lower + 1)))
    }
    
    func delay(_ delay:Double, closure:@escaping ()->()) {
        
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
    }
    
    //Deals With Collisions
    func charDidCollideWithRock(){
        
        if muted == false {
            AudioServicesPlaySystemSound(self.sfxBump)
        }
        
        let deadMonkey = SKSpriteNode(imageNamed: "monkeyDead")
        deadMonkey.position = character.position
        
        character.removeFromParent()
        self.dead = true
        self.addChild(deadMonkey)
        
        //End Game
        if(self.count > highScore) {
            highScore = self.count
            let highScoreDefault = UserDefaults.standard
            highScoreDefault.setValue(highScore, forKey: "highScore")
            highScoreDefault.synchronize()
        }
        roundScore = self.count
        let roundScoreDefault = UserDefaults.standard
        roundScoreDefault.setValue(roundScore, forKey: "roundScore")
        roundScoreDefault.synchronize()
        if muted == false {
            backgroundMusicPlayer.stop()
        }
        
        if let scene = EndGameScene(fileNamed: "EndGameScene") {
            // set the scale mode to fit the the window
            scene.scaleMode = .aspectFit
            
            //present the scene
            view!.presentScene(scene, transition:SKTransition.flipHorizontal(withDuration: TimeInterval(1.0)))
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        firstBody = contact.bodyA
        secondBody = contact.bodyB
        
        //Laser Hits TempRock
        if (firstBody.categoryBitMask == 0b11 && secondBody.categoryBitMask == 0b1
            || firstBody.categoryBitMask == 0b1 && secondBody.categoryBitMask == 0b11){
            
            if (firstBody.categoryBitMask > secondBody.categoryBitMask){
                firstBody.node?.removeFromParent()
                secondBody.node?.removeFromParent()
                if muted == false {
                    AudioServicesPlaySystemSound(self.sfxSplat)
                }
            }
            else{
                firstBody.node?.removeFromParent()
                secondBody.node?.removeFromParent()
                if muted == false {
                    AudioServicesPlaySystemSound(self.sfxSplat)
                }
            }
        }
        
        //Laser Hits Rock
        if (firstBody.categoryBitMask == 0b11 && secondBody.categoryBitMask == 0b10
            || firstBody.categoryBitMask == 0b10 && secondBody.categoryBitMask == 0b11){
            
            if (firstBody.categoryBitMask > secondBody.categoryBitMask){
                firstBody.node?.removeFromParent()
                if muted == false {
                    AudioServicesPlaySystemSound(self.sfxSplat)
                }
            }
            else{
                secondBody.node?.removeFromParent()
                if muted == false {
                    AudioServicesPlaySystemSound(self.sfxSplat)
                }
            }
        }
        
        //Char Hits TempRock
        if (firstBody.categoryBitMask == 0b100 && secondBody.categoryBitMask == 0b1
            || firstBody.categoryBitMask == 0b1 && secondBody.categoryBitMask == 0b100){
            
            if (firstBody.categoryBitMask > secondBody.categoryBitMask){
                charDidCollideWithRock()
            }
            else{
                charDidCollideWithRock()
            }
        }
        
        //Char Hits Rock
        if (firstBody.categoryBitMask == 0b100 && secondBody.categoryBitMask == 0b10
            || firstBody.categoryBitMask == 0b10 && secondBody.categoryBitMask == 0b100){
            
            if (firstBody.categoryBitMask > secondBody.categoryBitMask){
                charDidCollideWithRock()
            }
            else{
                charDidCollideWithRock()
            }
        }
    }
    
    func playBackgroundMusic() {
        
        let audioSession = AVAudioSession.sharedInstance()
        try!audioSession.setCategory(AVAudioSessionCategoryPlayback, with: AVAudioSessionCategoryOptions.mixWithOthers)
        
        if let path = Bundle.main.path(forResource: "funky", ofType: "mp3") {
            let filePath = NSURL(fileURLWithPath:path)
            backgroundMusicPlayer = try! AVAudioPlayer.init(contentsOf: filePath as URL)
            backgroundMusicPlayer.numberOfLoops = -1 //logic for infinite loop
            backgroundMusicPlayer.prepareToPlay()
            backgroundMusicPlayer.play()
        }
        
    }
}

