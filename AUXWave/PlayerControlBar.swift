//
//  PlayerControlBar.swift
//  AUXWave
//
//  Created by Nico Cvitak on 2015-03-14.
//  Copyright (c) 2015 UW-AppDEV. All rights reserved.
//

import UIKit

class PlayerControlBar: UIToolbar {
    
    private var playButton: UIBarButtonItem?
    private var pauseButton: UIBarButtonItem?
    private var backButton: UIBarButtonItem?
    private var nextButton: UIBarButtonItem?
    
    private let fixedSpace: UIBarButtonItem = {
        let space = UIBarButtonItem(barButtonSystemItem: .FixedSpace, target: nil, action: nil)
        space.width = 42
        return space
        }()
    
    var player: PlaylistPlayer?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        playButton = UIBarButtonItem(barButtonSystemItem: .Play, target: self, action: "play")
        pauseButton = UIBarButtonItem(barButtonSystemItem: .Pause, target: self, action: "pause")
        backButton = UIBarButtonItem(barButtonSystemItem: .Rewind, target: self, action: "back")
        nextButton = UIBarButtonItem(barButtonSystemItem: .FastForward, target: self, action: "next")
        
        self.items = [
            UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil),
            backButton!,
            fixedSpace,
            playButton!,
            fixedSpace,
            nextButton!,
            UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
        ]
        
        self.setBackgroundImage(UIImage(), forToolbarPosition: .Any, barMetrics: .Default)
        self.backgroundColor = UIColor.clearColor()
        self.clipsToBounds = true
        
    }

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    func play() {
        if let player = self.player {
            if player.paused() {
                player.play()
                self.items?[3] = pauseButton!
            }
        }
    }
    
    func pause() {
        if let player = self.player {
            if !player.paused() {
                player.pause()
                self.items?[3] = playButton!
            }
        }
    }
    
    func back() {
        if let player = self.player {
            player.previousTrack()
        }
    }
    
    func next() {
        if let player = self.player {
            player.nextTrack()
        }
    }

}
