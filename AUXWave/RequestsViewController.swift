//
//  RequestsViewController.swift
//  AUXWave
//
//  Created by Nico Cvitak on 2015-03-14.
//  Copyright (c) 2015 UW-AppDEV. All rights reserved.
//

import UIKit

class RequestsViewController: UIViewController, FBLoginViewDelegate {

    @IBOutlet private var facebookLoginView: FBLoginView?
    @IBOutlet private var facebookProfilePictureView: FBProfilePictureView?
    @IBOutlet private var djNameLabel: UILabel?
    
    @IBOutlet private var serviceStateView: UIView?
    @IBOutlet private var serviceStateImageView: UIImageView?
    @IBOutlet private var serviceStateSwitch: UISwitch?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // Add circle mask to djImageView
        if let facebookProfilePictureView = self.facebookProfilePictureView {
            facebookProfilePictureView.layer.cornerRadius = facebookProfilePictureView.frame.size.width / 2.0
            facebookProfilePictureView.layer.masksToBounds = true
        }
        
        facebookLoginView?.delegate = self
        djNameLabel?.text = UIDevice.currentDevice().name
        
        if let serviceStateView = self.serviceStateView {
            serviceStateView.layer.cornerRadius = 3.0
            serviceStateView.layer.masksToBounds = true
        }
        
        serviceStateSwitch?.on = DJService.localService().isActive
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func loginViewFetchedUserInfo(loginView: FBLoginView!, user: FBGraphUser!) {
        
        let userState = UserState.localUserState()
        
        userState.displayName = user.name
        userState.facebookID = user.objectID
        
        self.djNameLabel?.text = userState.displayName
        self.facebookProfilePictureView?.profileID = userState.facebookID
        
    }
    
    func loginViewShowingLoggedOutUser(loginView: FBLoginView!) {
        let userState = UserState.localUserState()
        
        userState.displayName = UIDevice.currentDevice().name
        userState.facebookID = nil
        
        self.djNameLabel?.text = userState.displayName
        self.facebookProfilePictureView?.profileID = userState.facebookID
        
    }
    
    @IBAction func serviceStateChange(switchState: UISwitch) {
        if switchState.on {
            serviceStateImageView?.image = kAUXWaveServiceOnImage
            let userState = UserState.localUserState()
            
            let displayName = userState.displayName
            var discoveryInfo: [NSObject : AnyObject] = [:]
            discoveryInfo["facebookID"] = userState.facebookID
            
            DJService.localService().start(displayName!, discoveryInfo: discoveryInfo)
        } else {
            serviceStateImageView?.image = kAUXWaveServiceOffImage
            DJService.localService().stop()
        }
    }

}
