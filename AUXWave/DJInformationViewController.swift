//
//  DJInformationViewController.swift
//  AUXWave
//
//  Created by Nico Cvitak on 2015-03-01.
//  Copyright (c) 2015 UW-AppDEV. All rights reserved.
//

import UIKit
import MultipeerConnectivity
import AVFoundation
import MediaPlayer

class DJInformationViewController: UIViewController, MPMediaPickerControllerDelegate, MCSessionDelegate {
    
    let mediaPickerController = MPMediaPickerController(mediaTypes: MPMediaType.Music)
    
    @IBOutlet private var djImageView: FBProfilePictureView?
    @IBOutlet private var djLabel: UILabel?
    
    @IBOutlet private var blurAlbumArtworkImageView: UIImageView?
    @IBOutlet private var albumArtworkImageView: UIImageView?
    
    @IBOutlet private var songTitleLabel: UILabel?
    @IBOutlet private var songArtistAndAlbumLabel: UILabel?
    
    @IBOutlet private var makeRequestBarButtonItem: UIBarButtonItem?
    
    
    var djFacebookID: String? {
        didSet {
            djImageView?.profileID = djFacebookID
        }
    }
    
    var djName: String? {
        didSet {
            djLabel?.text = djName
        }
    }
    
    var peerID: MCPeerID?
    var browser: MCNearbyServiceBrowser?
    var session: MCSession?
    var discoveryInfo: [NSObject : AnyObject]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        // Add circle mask to djImageView
        if let imageView = djImageView {
            imageView.layer.cornerRadius = imageView.frame.size.width / 2.0
            imageView.layer.masksToBounds = true
        }
        
        // Update Views
        djImageView?.profileID = djFacebookID
        djLabel?.text = djName
        
        session = MCSession(peer: browser?.myPeerID, securityIdentity: nil, encryptionPreference: .None)
        session?.delegate = self
        browser?.invitePeer(peerID, toSession: session, withContext: nil, timeout: 0)
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
        
        if let item = mediaItemCollection.items.first as? MPMediaItem {
            
            let fileManager = NSFileManager.defaultManager()
            
            if let cachePath = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true).first as? String {
                
                let resourceName = "\(item.hash).m4a"
                
                let exportURL = NSURL(fileURLWithPath: cachePath.stringByAppendingPathComponent(resourceName))
                
                // Initialize exporter for M4A
                let exporter = MediaItemExporter(mediaItem: item)
                exporter.m4aOutputURL = exportURL
                
                
                
                println("exporting: \(exporter.m4aOutputURL)")
                exporter.exportAsynchronouslyWithCompletionHandler({
                    
                    
                    let status = exporter.status
                    
                    if status == .Completed {
                        println("completed")
                        
                        var error: NSError?
                        let plItem = PlaylistItem(URL: exportURL)
                        println(plItem.title)
                        println(plItem.artist)
                        println(plItem.albumName)
                        println(plItem.artwork?.size.height)
                        
                        // begin transfer
                        
                        self.session?.sendResourceAtURL(exportURL, withName: resourceName, toPeer: self.peerID, withCompletionHandler: { (error: NSError!) in
                            if error != nil {
                                println(error)
                            } else {
                                println("transfer complete!")
                            }
                        })
                        
                        
                    } else if status == .Failed {
                        println("export FAILED!")
                        println("error: \(exporter.error)")
                        fileManager.removeItemAtURL(exportURL!, error: nil)
                    }
                    
                })
                
                
            }
            
        }
        
        
        mediaPicker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func mediaPickerDidCancel(mediaPicker: MPMediaPickerController!) {
        mediaPicker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    /*
    // MARK: - MCSessionDelegate
    */
    
    func session(session: MCSession!, didReceiveData data: NSData!, fromPeer peerID: MCPeerID!) {
        
        let archive = NSKeyedUnarchiver(forReadingWithData: data)
        
        let title = archive.decodeObjectForKey("title") as? String
        let artist = archive.decodeObjectForKey("artist") as? String
        let album = archive.decodeObjectForKey("album") as? String
        let artwork = archive.decodeObjectForKey("artwork") as? UIImage
        
        if title != nil {
            
            dispatch_async(dispatch_get_main_queue(), {
                
                self.blurAlbumArtworkImageView?.image = artwork
                self.albumArtworkImageView?.image = artwork
                
                self.songTitleLabel?.text = title
                self.songArtistAndAlbumLabel?.text = "\(artist) | \(album)"
                
            })
            
        }
    }
    
    func session(session: MCSession!, didReceiveStream stream: NSInputStream!, withName streamName: String!, fromPeer peerID: MCPeerID!) {
        
    }
    
    func session(session: MCSession!, didStartReceivingResourceWithName resourceName: String!, fromPeer peerID: MCPeerID!, withProgress progress: NSProgress!) {
        
    }
    
    func session(session: MCSession!, didFinishReceivingResourceWithName resourceName: String!, fromPeer peerID: MCPeerID!, atURL localURL: NSURL!, withError error: NSError!) {
        
    }
    
    func session(session: MCSession!, peer peerID: MCPeerID!, didChangeState state: MCSessionState) {
        
        if state == MCSessionState.NotConnected {
            println("not connected")
        }
        
        if state == MCSessionState.Connecting {
            println("connecting")
        }
        
        if state == .Connected {
            println("connected!")
            
            if let makeRequestBarButtonItem = makeRequestBarButtonItem {
                dispatch_async(dispatch_get_main_queue(), {
                    makeRequestBarButtonItem.enabled = true
                })
            }
            
        } else {
            if let makeRequestBarButtonItem = makeRequestBarButtonItem {
                dispatch_async(dispatch_get_main_queue(), {
                    makeRequestBarButtonItem.enabled = false
                })
            }
        }
        
        if peerID == self.peerID {
            // We can only make requests if we are connected with the dj
            
        }
    }
    
    func session(session: MCSession!, didReceiveCertificate certificate: [AnyObject]!, fromPeer peerID: MCPeerID!, certificateHandler: ((Bool) -> Void)!) {
        certificateHandler(true)
    }
    
}
