//
//  InstructionScene.swift
//  Project Space Monkey
//
//  Created by Binh Le on 12/30/16.
//  Copyright © 2016 Binh Le. All rights reserved.
//

import Foundation
import SpriteKit


class HowToPlayScene: SKScene {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    
        for touch in touches {
            
            let location = touch.location(in: self)
            if atPoint(location).name == "Start" {
                if let scene = GameScene(fileNamed: "GameScene") {
                    // set the scale mode to fit the the window
                    scene.scaleMode = .aspectFit
                    
                    //present the scene
                    view!.presentScene(scene, transition:SKTransition.flipHorizontal(withDuration: TimeInterval(1.0)))
                }
            }
        }
    }

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
