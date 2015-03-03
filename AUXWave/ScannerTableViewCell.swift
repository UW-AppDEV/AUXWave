//
//  ScannerTableViewCell.swift
//  AUXWave
//
//  Created by Nico Cvitak on 2015-03-01.
//  Copyright (c) 2015 UW-AppDEV. All rights reserved.
//

import UIKit
import QuartzCore

class ScannerTableViewCell: UITableViewCell {

    @IBOutlet var djImageView: FacebookProfileImageView?
    @IBOutlet var djLabel: UILabel?
    
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
