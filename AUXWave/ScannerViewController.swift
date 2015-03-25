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
    
    var browser: MCNearbyServiceBrowser?
    
    var discoveredPeers: [MCPeerID : [NSObject : AnyObject]?] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        let userState = UserState.localUserState()
        
        peerID = MCPeerID(displayName: userState.displayName)
        browser = MCNearbyServiceBrowser(peer: peerID, serviceType: kServiceTypeAUXWave)
        browser?.delegate = self
        
        // Sample Data
        //discoveredPeers[MCPeerID(displayName: "Nico Cvitak")] = ["facebookID" : "ncvitak"]
        
        // Start searching for DJs when the view is visible
        browser?.startBrowsingForPeers()
        println("load")
    }
    
    override func viewWillAppear(animated: Bool) {
        
        if let selectedRow = self.tableView.indexPathForSelectedRow() {
            self.tableView.deselectRowAtIndexPath(selectedRow, animated: animated)
        }
        
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        // Stop searching for DJs when the view is not visible
        //browser?.stopBrowsingForPeers()
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
                djInformationViewController.peerID = selectedCell.peerID
                djInformationViewController.djFacebookID = selectedCell.facebookID
                djInformationViewController.djName = selectedCell.peerID?.displayName
                djInformationViewController.browser = self.browser
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
        cell.peerID = peerID
        
        // Load information from Facebook
        cell.facebookID = discoveryInfo??["facebookID"] as? String
        
        return cell
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return discoveredPeers.keys.array.count
    }
    
    /*
    // MARK: - MCNearbyServiceBrowserDelegate
    */
    
    func browser(browser: MCNearbyServiceBrowser!, foundPeer peerID: MCPeerID!, withDiscoveryInfo info: [NSObject : AnyObject]!) {
        println("found: \(peerID.displayName)")
        tableView.beginUpdates()
        
        discoveredPeers[peerID] = info
        
        if let index = find(discoveredPeers.keys.array, peerID) {
            tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: index, inSection: 0)], withRowAnimation: .Fade)
        }
        
        tableView.endUpdates()
    }
    
    func browser(browser: MCNearbyServiceBrowser!, lostPeer peerID: MCPeerID!) {
        
        tableView.beginUpdates()
        
        if let index = find(discoveredPeers.keys.array, peerID) {
            tableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: index, inSection: 0)], withRowAnimation: .Fade)
        }
        
        discoveredPeers.removeValueForKey(peerID)
            
        tableView.endUpdates()
    }
    
    /*
    // MARK: - Received Actions
    */

}
