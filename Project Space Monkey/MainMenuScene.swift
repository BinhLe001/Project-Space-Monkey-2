//
//  MainMenuScene.swift
//  Project Space Monkey
//
//  Created by Binh Le on 12/30/16.
//  Copyright © 2016 Binh Le. All rights reserved.
//

import SpriteKit
import GameKit

class MainMenuScene: SKScene, GKGameCenterControllerDelegate {
    
    var highScore = Int()
    
    override func didMove(to view: SKView) {
        
        self.initScroll()

        let dust = SKSpriteNode(imageNamed: "spacedust")
        dust.position = CGPoint(x: 0, y: 0)
        dust.size = self.frame.size
        self.addChild(dust)
        
        let dustDestination = CGPoint(x: 0, y: -self.frame.size.height)
        let dustAction = SKAction.move(to: dustDestination, duration: 5.00)
        let dustActionDone = SKAction.removeFromParent()
        dust.run(SKAction.sequence([dustAction, dustActionDone]))
        
        //// SAVING HIGH SCORE
        let highScoreDefault = UserDefaults.standard
        if(highScoreDefault.value(forKey: "highScore") != nil) {
            highScore = highScoreDefault.value(forKey: "highScore") as! NSInteger!
        }
        saveHighScore(number: highScore)
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch in touches {
            let location =  touch.location(in: self)
            
            if atPoint(location).name == "Start" {
                if let scene = GameScene(fileNamed: "GameScene") {
                    //set the mode to fit the window
                    scene.scaleMode = .aspectFit
                    
                    //present the scene
                    view!.presentScene(scene, transition: SKTransition.flipHorizontal(withDuration: (1.0)))
                }
            }
            if atPoint(location).name == "Leaderboard" {
                showLeaderboard()
            }
            
            if atPoint(location).name == "Howtoplay" {
                if let scene = HowToPlayScene(fileNamed: "HowToPlayScene") {
                    scene.scaleMode = .aspectFit
                    
                    view!.presentScene(scene, transition: SKTransition.flipHorizontal(withDuration: (1.0)))
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
    
    func saveHighScore(number: Int) {
        if GKLocalPlayer.localPlayer().isAuthenticated {
            let scoreReporter = GKScore(leaderboardIdentifier: "High_Scores")
            
            scoreReporter.value = Int64(number)
            let scoreArray : [GKScore] =  [scoreReporter]
            
            GKScore.report(scoreArray, withCompletionHandler: nil)
        }
    }
    
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true, completion: nil)
    }
    
    func showLeaderboard() {
        let viewController = self.view?.window?.rootViewController
        let gcvc = GKGameCenterViewController()
        
        gcvc.gameCenterDelegate = self
        
        viewController?.present(gcvc, animated: true, completion: nil)
    }
}

