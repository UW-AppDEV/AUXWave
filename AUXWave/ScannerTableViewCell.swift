//
//  ScannerTableViewCell.swift
//  AUXWave
//
//  Created by Nico Cvitak on 2015-03-01.
//  Copyright (c) 2015 UW-AppDEV. All rights reserved.
//

import UIKit
import QuartzCore
import MultipeerConnectivity

class ScannerTableViewCell: UITableViewCell {

    var peerID: MCPeerID? {
        didSet {
            djLabel?.text = peerID?.displayName
        }
    }
    
    var facebookID: String? {
        didSet {
            djImageView?.profileID = facebookID
        }
    }
    
    @IBOutlet private var djImageView: FBProfilePictureView?
    @IBOutlet private var djLabel: UILabel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        // Add circle mask to djImageView
        if let imageView = djImageView {
            imageView.layer.cornerRadius = imageView.frame.size.width / 2.0
            imageView.layer.masksToBounds = true
        }
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
