//
//  UserState.swift
//  AUXWave
//
//  Created by Nico Cvitak on 2015-03-14.
//  Copyright (c) 2015 UW-AppDEV. All rights reserved.
//

import UIKit

class UserState: NSObject {
    
    private struct Singleton {
        static let instance = UserState()
    }
    
    class func localUserState() -> UserState {
        return Singleton.instance
    }
    
    var displayName: String?
    var facebookID: String?
    
    private override init() {
        displayName = UIDevice.currentDevice().name
        facebookID = nil
    }
    
}
