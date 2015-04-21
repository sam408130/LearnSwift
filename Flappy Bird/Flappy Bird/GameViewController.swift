//
//  GameViewController.swift
//  Flappy Bird
//
//  Created by Rob Percival on 22/08/2014.
//  Copyright (c) 2014 Appfish. All rights reserved.
//

import UIKit
import SpriteKit

extension SKNode {
    class func unarchiveFromFile(file : NSString) -> SKNode? {
        // Updated - added as? String
        
        if let path = NSBundle.mainBundle().pathForResource(file as? String, ofType: "sks") {
            
            /* Update - replaced
            
            var sceneData = NSData.dataWithContentsOfFile(path, options: .DataReadingMappedIfSafe, error: nil)
            
            with
            
            var sceneData: AnyObject? = NSData.dataWithContentsOfMappedFile(path)
            
            */
            
            
            var sceneData: AnyObject? = NSData.dataWithContentsOfMappedFile(path)
            
            // Update - added as! NSData
            
            var archiver = NSKeyedUnarchiver(forReadingWithData: sceneData as! NSData)
            
            archiver.setClass(self.classForKeyedUnarchiver(), forClassName: "SKScene")
            
            // Update - replaced as with as!
            
            let scene = archiver.decodeObjectForKey(NSKeyedArchiveRootObjectKey) as! GameScene
            archiver.finishDecoding()
            return scene
        } else {
            return nil
        }
    }
}

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        if let scene = GameScene.unarchiveFromFile("GameScene") as? GameScene {
            // Configure the view.
            
            // Update - changed as to as!
            
            let skView = self.view as! SKView
            
            skView.showsFPS = true
            skView.showsNodeCount = true
            
            /* Sprite Kit applies additional optimizations to improve rendering performance */
            skView.ignoresSiblingOrder = true
            
            /* Set the scale mode to scale to fit the window */
            scene.scaleMode = .AspectFill
            
            skView.presentScene(scene)
        }
    }

    override func shouldAutorotate() -> Bool {
        return true
    }

    override func supportedInterfaceOrientations() -> Int {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            
            // Update - replaced toRaw() with rawValue
            
            return Int(UIInterfaceOrientationMask.AllButUpsideDown.rawValue)
        } else {
            
            // Update - replaced toRaw() with rawValue
            
            return Int(UIInterfaceOrientationMask.All.rawValue)
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
