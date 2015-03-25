//
//  AppDelegate.swift
//  AUXWave
//
//  Created by Nico Cvitak on 2015-02-28.
//  Copyright (c) 2015 UW-AppDEV. All rights reserved.
//

import UIKit
import AVFoundation

let kServiceTypeAUXWave = "AUXWave"
let kDefaultDJImage = UIImage(named: "AUXWaveDefaultDJ")
let kAUXWaveServiceOffImage = UIImage(named: "AUXWaveServiceOff")
let kAUXWaveServiceOnImage = UIImage(named: "AUXWaveServiceOn")
let kAUXWaveTintColor = UIColor(red: 255.0 / 255.0, green: 45.0 / 255.0, blue: 85.0 / 255.0, alpha: 255.0 / 255.0)
let kAlbumArtworkSize = CGSizeMake(256.0, 256.0)


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        // FacebookSDK documentation says to do this :P
        FBLoginView.classForCoder()
        FBProfilePictureView.classForCoder()
        
        // Get audio seesion
        let audioSession = AVAudioSession.sharedInstance()
        
        // Activate session for background playback
        if audioSession.setCategory(AVAudioSessionCategoryPlayback, error: nil) {
            audioSession.setActive(true, error: nil)
        }
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        // FacebookSDK documentation says to do this :P
        FBAppEvents.activateApp()
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func applicationDidReceiveMemoryWarning(application: UIApplication) {
        // Dispose of any resources that can be recreated.
        
        // Clear caches
        PlaylistItem.clearImageCache()
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
        
        // FacebookSDK documentation says to do this :P
        return FBAppCall.handleOpenURL(url, sourceApplication: sourceApplication)
    }
    
}

