//
//  ViewController.swift
//  AUXWave
//
//  Created by Nico Cvitak on 2015-02-28.
//  Copyright (c) 2015 UW-AppDEV. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer
import MultipeerConnectivity

class ViewController: UIViewController, MPMediaPickerControllerDelegate, UIActionSheetDelegate, UITableViewDataSource, UITableViewDelegate, PlaylistPlayerDelegate, DJServiceDelegate {
    
    private let mediaPicker = MPMediaPickerController(mediaTypes: .Music)
    private var clearPlaylistActionSheet: UIActionSheet?
    
    private var player: PlaylistPlayer?
    private var toolbarIdleItems: [UIBarButtonItem]?
    private var toolbarEditItems: [UIBarButtonItem]?
    
    @IBOutlet private var blurAlbumArtworkImageView: UIImageView?
    @IBOutlet private var toolbar: UIToolbar?
    @IBOutlet private var tableView: UITableView?
    @IBOutlet private var controlBar: PlayerControlBar?
    @IBOutlet private var volumeView: MPVolumeView?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        mediaPicker.allowsPickingMultipleItems = true
        mediaPicker.showsCloudItems = false
        mediaPicker.delegate = self
        
        clearPlaylistActionSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: "Clear")
        clearPlaylistActionSheet?.tintColor = self.view.tintColor
        
        toolbarIdleItems = [
            UIBarButtonItem(barButtonSystemItem: .Edit, target: self, action: "editPlaylist"),
            UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil),
            UIBarButtonItem(barButtonSystemItem: .Trash, target: self, action: "clearPlaylist")
        ]
        toolbarEditItems = [
            UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "doneEditingPlaylist"),
            UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil),
            UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Refresh, target: self, action: "shufflePlaylist"),
            UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil),
            UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "addItemsToPlaylist")
        ]
        
        toolbar?.items = toolbarIdleItems
        
        player = PlaylistPlayer()
        player?.delegate = self
        
        tableView?.dataSource = self
        tableView?.delegate = self
        
        controlBar?.player = player
        
        volumeView?.showsVolumeSlider = true
        volumeView?.showsRouteButton = false
        volumeView?.sizeToFit()
        
        DJService.localService().delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        //self.navigationController?.navigationBarHidden = true
    }
    
    override func viewWillDisappear(animated: Bool) {
        //self.navigationController?.navigationBarHidden = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    func editPlaylist() {
        tableView?.setEditing(true, animated: true)
        toolbar?.setItems(toolbarEditItems, animated: false)
    }
    
    func clearPlaylist() {
        clearPlaylistActionSheet?.showInView(self.view)
    }
    
    func doneEditingPlaylist() {
        tableView?.setEditing(false, animated: true)
        toolbar?.setItems(toolbarIdleItems, animated: false)
        
    }
    
    func addItemsToPlaylist() {
        self.presentViewController(mediaPicker, animated: true, completion: nil)
    }
    
    func shufflePlaylist() {
        player?.shuffle()
        tableView?.reloadData()
    }
    
    
    func mediaPicker(mediaPicker: MPMediaPickerController!, didPickMediaItems mediaItemCollection: MPMediaItemCollection!) {
        
        let items: [PlaylistItem] = map(mediaItemCollection.items, {($0 as MPMediaItem).asPlaylistItem() })
        player?.playlist.extend(items)
        
        mediaPicker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func mediaPickerDidCancel(mediaPicker: MPMediaPickerController!) {
        mediaPicker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        if actionSheet == clearPlaylistActionSheet && buttonIndex == 0 {
            player?.playlist.removeAll(keepCapacity: false)
            tableView?.reloadData()
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("PlaylistTableViewCell") as PlaylistTableViewCell
        
        let item = player?.playlist[indexPath.row]
        
        cell.albumArtworkImageView?.image = player?.playlist[indexPath.row].artwork
        cell.titleLabel?.text = item?.title
        if item?.artist != nil && item?.albumName != nil {
            cell.artistAndAlbumNameLabel?.text = "\(item!.artist!) | \(item!.albumName!)"
        }
        
        if player?.currentItem == item {
            cell.titleLabel?.textColor = kAUXWaveTintColor
            cell.artistAndAlbumNameLabel?.textColor = kAUXWaveTintColor
        } else {
            cell.titleLabel?.textColor = UIColor.whiteColor()
            cell.artistAndAlbumNameLabel?.textColor = UIColor.whiteColor()
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let player = self.player {
            return player.playlist.count
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            player?.playlist.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
    }
    
    func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        if let item = player?.playlist[sourceIndexPath.row] {
            player?.playlist.removeAtIndex(sourceIndexPath.row)
            player?.playlist.insert(item, atIndex: destinationIndexPath.row)
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        player?.setCurrentItemFromIndex(indexPath.row)
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.backgroundColor = UIColor.clearColor()
    }
    
    func player(playlistPlayer: PlaylistPlayer, didChangeCurrentPlaylistItem playlistItem: PlaylistItem?) {
        blurAlbumArtworkImageView?.image = playlistItem?.artwork
        tableView?.reloadData()
    }
    
    func service(service: DJService, didReceivePlaylistItem item: PlaylistItem, fromPeer peerID: MCPeerID) {
        tableView?.beginUpdates()
        
        if let player = player {
            player.playlist.append(item)
            
            if let index = find(player.playlist, item) {
                tableView?.insertRowsAtIndexPaths([NSIndexPath(forRow: index, inSection: 0)], withRowAnimation: .Fade)
            }
        }
        
        tableView?.endUpdates()
    }
}

