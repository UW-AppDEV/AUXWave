//
//  DJInformationViewController.swift
//  AUXWave
//
//  Created by Nico Cvitak on 2015-03-01.
//  Copyright (c) 2015 UW-AppDEV. All rights reserved.
//

import UIKit
import MultipeerConnectivity
import MediaPlayer

class DJInformationViewController: UIViewController, MPMediaPickerControllerDelegate {

    let mediaPickerController = MPMediaPickerController(mediaTypes: MPMediaType.Music)
    
    @IBOutlet var djImageView: UIImageView?
    @IBOutlet var djLabel: UILabel?
    
    var djImage: UIImage?
    var djName: String?
    
    var peerID: MCPeerID?
    var discoveryInfo: [NSObject : AnyObject]?
    var session: MCSession?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // Add circle mask to djImageView
        if let imageView = djImageView {
            imageView.layer.cornerRadius = imageView.frame.size.width / 2.0
            imageView.layer.masksToBounds = true
        }
        
        djImageView?.image = djImage
        djLabel?.text = djName
        
    }
    
    override func viewWillAppear(animated: Bool) {
        navigationController?.toolbarHidden = false
    }
    
    override func viewWillDisappear(animated: Bool) {
        navigationController?.toolbarHidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    // MARK: - Received Actions
    */
    
    @IBAction func makeRequest() {
        
        mediaPickerController.delegate = self
        mediaPickerController.allowsPickingMultipleItems = false
        mediaPickerController.showsCloudItems = false
        
        self.presentViewController(mediaPickerController, animated: true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    /*
    // MARK: - MPMediaPickerControllerDelegate
    */

    func mediaPicker(mediaPicker: MPMediaPickerController!, didPickMediaItems mediaItemCollection: MPMediaItemCollection!) {
        mediaPicker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func mediaPickerDidCancel(mediaPicker: MPMediaPickerController!) {
        mediaPicker.dismissViewControllerAnimated(true, completion: nil)
    }

}
