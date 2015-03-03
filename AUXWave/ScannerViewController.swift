//
//  ScannerViewController.swift
//  AUXWave
//
//  Created by Nico Cvitak on 2015-02-28.
//  Copyright (c) 2015 UW-AppDEV. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class ScannerViewController: UITableViewController, UITableViewDataSource, MCNearbyServiceBrowserDelegate {
    
    var peerID: MCPeerID?
    var session: MCSession?
    
    var browser: MCNearbyServiceBrowser?
    
    var discoveredPeers: [MCPeerID : [NSObject : AnyObject]] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        peerID = MCPeerID(displayName: UIDevice.currentDevice().name)
        session = MCSession(peer: peerID)
        
        browser = MCNearbyServiceBrowser(peer: peerID, serviceType: kServiceTypeAUXWave)
        
        // Sample Data
        discoveredPeers[MCPeerID(displayName: "Nico Cvitak")] = ["facebookID" : "ncvitak"]
    }
    
    override func viewWillAppear(animated: Bool) {
        
        if let selectedRow = self.tableView.indexPathForSelectedRow() {
            self.tableView.deselectRowAtIndexPath(selectedRow, animated: animated)
        }
        
        // Start searching for DJs when the view is visible
        browser?.startBrowsingForPeers()
    }
    
    override func viewWillDisappear(animated: Bool) {
        // Stop searching for DJs when the view is not visible
        browser?.stopBrowsingForPeers()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    // MARK: - Navigation
    */
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if let djInformationViewController = segue.destinationViewController as? DJInformationViewController {
            
            if let selectedCell = sender as? ScannerTableViewCell {
                djInformationViewController.djImage = selectedCell.djImageView?.image
                djInformationViewController.djName = selectedCell.djLabel?.text
            }
            
        }
    }
    
    /*
    // MARK: - UITableViewDataSource
    */
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let peerID = discoveredPeers.keys.array[indexPath.row]
        let discoveryInfo = discoveredPeers[peerID]
        
        // Load ScannerTableViewCell
        let cell = tableView.dequeueReusableCellWithIdentifier("ScannerCell") as ScannerTableViewCell
        
        // Initialize default properties
        cell.djLabel?.text = peerID.displayName
        cell.djImageView?.image = kDefaultDJImage
        
        // Load information from Facebook
        if let facebookID = discoveryInfo?["facebookID"] as? String {
            
            if let image = facebookProfilePictureCache[facebookID] {
                cell.djImageView?.image = image
            } else {
                
                // Load profile picture asynchronously
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                    
                    let facebookProfilePictureURLString = "http://graph.facebook.com/\(facebookID)/picture?height=256&width=256"
                    
                    if let facebookProfilePictureURL = NSURL(string: facebookProfilePictureURLString) {
                        if let facebookProfilePictureData = NSData(contentsOfURL: facebookProfilePictureURL) {
                            
                            let facebookProfilePicture = UIImage(data: facebookProfilePictureData)
                            
                            // Update UI on main thread
                            dispatch_async(dispatch_get_main_queue(), {
                                if let image = facebookProfilePicture {
                                    facebookProfilePictureCache[facebookID] = image
                                    cell.djImageView?.image = image
                                }
                            })
                            
                        }
                    }
                    
                })
                
            }
            
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return discoveredPeers.keys.array.count
    }
    
    /*
    // MARK: - MCNearbyServiceBrowserDelegate
    */
    
    func browser(browser: MCNearbyServiceBrowser!, foundPeer peerID: MCPeerID!, withDiscoveryInfo info: [NSObject : AnyObject]!) {
        discoveredPeers[peerID] = info
    }
    
    func browser(browser: MCNearbyServiceBrowser!, lostPeer peerID: MCPeerID!) {
        discoveredPeers.removeValueForKey(peerID)
    }
    
    /*
    // MARK: - Received Actions
    */
    
    @IBAction func popToRootViewController() {
        navigationController?.popToRootViewControllerAnimated(true)
    }
    
}
