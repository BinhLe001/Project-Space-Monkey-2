//
//  GameViewController.swift
//  Project Space Monkey
//
//  Created by Binh Le on 12/30/16.
//  Copyright © 2016 Binh Le. All rights reserved.
//

import UIKit
import SpriteKit
import GameKit

class GameViewController: UIViewController {
    
    private var highScore = 0
    
    func authPlayer() {
        let localPlayer = GKLocalPlayer.localPlayer()
        localPlayer.authenticateHandler = {
            //A view controller and an error handler
            (view,error) in
            
            //If there is a view to work with
            if view != nil {
                self.present(view!, animated:true, completion: nil) //we dont want a completion handler
            }
                
            else{
                print(GKLocalPlayer.localPlayer().isAuthenticated)
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        authPlayer()
        
        
        
        if let view = self.view as! SKView? {
            // load the SKScene from 'MainMenuScene'
            if let scene = MainMenuScene(fileNamed: "MainMenu") {
                // set the scale mode to fit the the window
                scene.scaleMode = .aspectFit
                
                //present the scene
                view.presentScene(scene)
            }
            
            // view.ignoresSiblingOrder =  true
            // view.showsFPS =  true
            // view.showsNodeCount =  true
        }
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
