//
//  FacebookProfileImageView.swift
//  AUXWave
//
//  Created by Nico Cvitak on 2015-03-03.
//  Copyright (c) 2015 UW-AppDEV. All rights reserved.
//

import UIKit

private var facebookProfileImageCache: [String : UIImage] = [:]

class FacebookProfileImageView: UIImageView {
    
    class func clearImageCache() {
        facebookProfileImageCache.removeAll(keepCapacity: false)
    }
    
    var facebookID: String? {
        willSet {
            if let facebookID = newValue {
                
                let scale = UIScreen.mainScreen().scale
                let pixelSize = CGSizeMake(scale * self.frame.width, scale * self.frame.height)
                
                self.loadFacebookProfileImageAsync(facebookID: facebookID, size: pixelSize)
            }
        }
    }
    
    override var frame: CGRect {
        willSet {
            
            if self.facebookID != nil && newValue.size != frame.size {
                
                let scale = UIScreen.mainScreen().scale
                let pixelSize = CGSizeMake(scale * newValue.width, scale * newValue.height)
                
                self.loadFacebookProfileImageAsync(facebookID: self.facebookID!, size: pixelSize)
            }
        }
    }
    
    init(facebookID: String) {
        super.init()
        
        self.facebookID = facebookID
        self.loadFacebookProfileImageAsync(facebookID: facebookID, size: self.frame.size)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        facebookID = aDecoder.decodeObjectForKey("facebookID") as? String
    }
    
    override func encodeWithCoder(aCoder: NSCoder) {
        super.encodeWithCoder(aCoder)
        aCoder.encodeObject(facebookID, forKey: "facebookID")
    }
    
    private func loadFacebookProfileImageAsync(#facebookID: String, size: CGSize) {
        
        let cached = facebookProfileImageCache[facebookID]
        
        // Load cached image if available
        if cached != nil && cached?.size.width >= size.width && cached?.size.height >= size.height {
            self.image = cached
        } else {
            
            // Get profile image asynchronously
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                
                let urlString = "http://graph.facebook.com/\(facebookID)/picture?width=\(Int(size.width))&height=\(Int(size.height))"
                
                if let url = NSURL(string: urlString) {
                    if let data = NSData(contentsOfURL: url) {
                        if let image = UIImage(data: data) {
                            
                            // Update image on main thread
                            dispatch_sync(dispatch_get_main_queue(), {
                                facebookProfileImageCache[facebookID] = image
                                self.image = image
                            })
                            
                        }
                    }
                }
                
            })
            
        }
    }
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
}
