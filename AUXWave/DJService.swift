//
//  DJService.swift
//  AUXWave
//
//  Created by Nico Cvitak on 2015-03-14.
//  Copyright (c) 2015 UW-AppDEV. All rights reserved.
//

import UIKit
import MultipeerConnectivity

protocol DJServiceDelegate {
    func service(service: DJService, didReceivePlaylistItem item: PlaylistItem, fromPeer peerID: MCPeerID)
}

class DJService: NSObject, MCNearbyServiceAdvertiserDelegate, MCSessionDelegate {
    private struct Singleton {
        static let instance = DJService()
    }
    
    class func localService() -> DJService {
        return Singleton.instance
    }
    
    private var peerID: MCPeerID?
    private var advertiser: MCNearbyServiceAdvertiser?
    private var session: MCSession?
    private (set) var isActive: Bool = false
    
    var delegate: DJServiceDelegate?
    
    private override init() {
        
    }
    
    func start(displayName: String, discoveryInfo: [NSObject : AnyObject]!) {
        if isActive {
            self.stop()
        }
        
        peerID = MCPeerID(displayName: displayName)
        
        session = MCSession(peer: peerID)
        session?.delegate = self
        
        advertiser = MCNearbyServiceAdvertiser(peer: peerID, discoveryInfo: discoveryInfo, serviceType: kServiceTypeAUXWave)
        advertiser?.delegate = self
        advertiser?.startAdvertisingPeer()
        
        isActive = true
        println("start")
    }
    
    func stop() {
        if isActive {
            isActive = false
            
            advertiser?.stopAdvertisingPeer()
            advertiser = nil
            
            session = nil
            
            peerID = nil
        }
    }
    
    
    /*
    // MARK: - MCNearbyServiceAdvertiserDelegate
    */
    
    func advertiser(advertiser: MCNearbyServiceAdvertiser!, didReceiveInvitationFromPeer peerID: MCPeerID!, withContext context: NSData!, invitationHandler: ((Bool, MCSession!) -> Void)!) {
        invitationHandler(true, self.session)
    }
    
    /*
    // MARK: - MCSession
    */
    
    func session(session: MCSession!, didReceiveData data: NSData!, fromPeer peerID: MCPeerID!) {
        
    }
    
    func session(session: MCSession!, didReceiveStream stream: NSInputStream!, withName streamName: String!, fromPeer peerID: MCPeerID!) {
        
    }
    
    func session(session: MCSession!, didStartReceivingResourceWithName resourceName: String!, fromPeer peerID: MCPeerID!, withProgress progress: NSProgress!) {
        println("incoming: \(resourceName!)")
    }
    
    func session(session: MCSession!, didFinishReceivingResourceWithName resourceName: String!, fromPeer peerID: MCPeerID!, atURL localURL: NSURL!, withError error: NSError!) {
        println("finished: \(resourceName!)")
        let fileManager = NSFileManager.defaultManager()
        
        if let cachePath = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true).first as? String {
            
            let itemURL = NSURL(fileURLWithPath: cachePath.stringByAppendingPathComponent(resourceName))
            fileManager.moveItemAtURL(localURL, toURL: itemURL!, error: nil)
            
            if let item = PlaylistItem(URL: itemURL) {
                println("received item: \(itemURL)")
                println("\(item.title)")
                println("\(item.artist)")
                println("\(item.albumName)")
                
                if let delegate = self.delegate {
                    dispatch_async(dispatch_get_main_queue(), {
                        delegate.service(self, didReceivePlaylistItem: item, fromPeer: peerID)
                    })
                }
                
            } else {
                fileManager.removeItemAtURL(itemURL!, error: nil)
            }
            
        }
        
    }
    
    func session(session: MCSession!, peer peerID: MCPeerID!, didChangeState state: MCSessionState) {
        if state == .Connected {
            println("connected!")
        } else if state == .Connecting {
            println("connecting...")
        } else if state == .NotConnected {
            println("not connected")
        }
    }
    
    func session(session: MCSession!, didReceiveCertificate certificate: [AnyObject]!, fromPeer peerID: MCPeerID!, certificateHandler: ((Bool) -> Void)!) {
        certificateHandler(true)
    }
}
