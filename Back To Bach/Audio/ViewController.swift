//
//  ViewController.swift
//  Audio
//
//  Created by Rob Percival on 13/03/2015.
//  Copyright (c) 2015 Appfish. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    var player:AVAudioPlayer = AVAudioPlayer()

    @IBAction func play(sender: AnyObject) {
        
        player.play()
        
    }
    
    @IBAction func sliderChanged(sender: AnyObject) {
        
        player.volume = sliderValue.value
        
    }
    
    @IBAction func pause(sender: AnyObject) {
        
        player.pause()
        
    }
    
    
    @IBAction func stop(sender: AnyObject) {
        
        player.stop()
        player.currentTime = 0;
        
    }
    
    @IBOutlet var sliderValue: UISlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var audioPath = NSBundle.mainBundle().pathForResource("bach1", ofType: "mp3")
        
        var error : NSError? = nil
        
        player = AVAudioPlayer(contentsOfURL: NSURL(string: audioPath!), error: &error)
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

