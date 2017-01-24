//
//  EndGameScene.swift
//  Project Space Monkey
//
//  Created by Binh Le on 12/30/16.
//  Copyright © 2016 Binh Le. All rights reserved.
//

import SpriteKit

class EndGameScene: SKScene{
    
    private var scoreLabel = SKLabelNode()
    private var highScoreLabel = SKLabelNode()
    private var highScore = 0
    private var roundScore = 0
    
    override func didMove(to view: SKView) {
        
        let dust = SKSpriteNode(imageNamed: "spacedust")
        dust.position = CGPoint(x: 0, y: 0)
        dust.size = self.frame.size
        self.addChild(dust)
        
        let dustDestination = CGPoint(x: 0, y: -self.frame.size.height)
        let dustAction = SKAction.move(to: dustDestination, duration: 5.00)
        let dustActionDone = SKAction.removeFromParent()
        dust.run(SKAction.sequence([dustAction, dustActionDone]))
        
        self.initScroll()

        //PULL HIGH SCORE FROM MEMORY
        let highScoreDefault = UserDefaults.standard
        if (highScoreDefault.value(forKey: "highScore") != nil) {
            highScore = highScoreDefault.value(forKey: "highScore") as! NSInteger!
        }
        let roundScoreDefault = UserDefaults.standard
        if (roundScoreDefault.value(forKey: "roundScore") != nil) {
            roundScore = roundScoreDefault.value(forKey: "roundScore") as! NSInteger!
        }
        
        // HIGH SCORE
        highScoreLabel = childNode(withName: "highScoreLabel") as! SKLabelNode
        highScoreLabel.text = "\(highScore)"
        
        //Round score
        scoreLabel = childNode(withName: "scoreLabel") as! SKLabelNode
        scoreLabel.text = "\(roundScore)"
    }
    
    //Detects Pressing Of Retry Button
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch in touches {
            
            let location = touch.location(in: self)
            
            if atPoint(location).name == "Howtoplay" {
                if let scene = HowToPlayScene(fileNamed: "HowToPlayScene") {
                    // set the scale mode to fit the the window
                    scene.scaleMode = .aspectFit
                    
                    //present the scene
                    view!.presentScene(scene, transition:SKTransition.flipHorizontal(withDuration: TimeInterval(1.0)))
                }
            }
            
            if atPoint(location).name == "NewGame" {
                if let scene = GameScene(fileNamed: "GameScene") {
                    // set the scale mode to fit the the window
                    scene.scaleMode = .aspectFit
                    
                    //present the scene
                    view!.presentScene(scene, transition:SKTransition.flipHorizontal(withDuration: TimeInterval(1.0)))
                }
            }
            
        }
    }
    
    //Scrolls Background
    func initScroll(){
        
        let dust = SKSpriteNode(imageNamed: "spacedust")
        dust.position = CGPoint(x: 0, y: self.frame.size.height)
        dust.size = self.frame.size
        self.addChild(dust)
        let dustDestination = CGPoint(x: 0, y: -self.frame.size.height)
        
        let dustAction = SKAction.move(to: dustDestination, duration: 10.00)
        let dustActionDone = SKAction.removeFromParent()
        dust.run(SKAction.sequence([dustAction, dustActionDone]))
        
        delay(4.75){
            self.initScroll()
        }
    }
    
    func delay(_ delay:Double, closure:@escaping ()->()) {
        
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
    }
}
