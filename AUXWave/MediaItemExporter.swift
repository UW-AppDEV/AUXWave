//
//  MediaItemExporter.swift
//  AUXWave
//
//  Created by Nico Cvitak on 2015-03-15.
//  Copyright (c) 2015 UW-AppDEV. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer

class MediaItemExporter: NSObject {
    private var exportSession: AVAssetExportSession
    
    var progress: Float {
        return exportSession.progress
    }
    
    var status: AVAssetExportSessionStatus {
        return exportSession.status
    }
    
    var error: NSError! {
        return exportSession.error
    }
    
    var estimatedOutputFileLength: Int64 {
        return exportSession.estimatedOutputFileLength
    }
    
    var m4aOutputURL: NSURL! {
        set {
            exportSession.outputURL = newValue
        }
        
        get {
            return exportSession.outputURL
        }
    }
    
    init(mediaItem: MPMediaItem) {
        self.exportSession = AVAssetExportSession(asset: AVURLAsset(URL: mediaItem.assetURL, options: nil), presetName: AVAssetExportPresetAppleM4A)
        super.init()
        
        let titleMetadataItem = AVMutableMetadataItem()
        titleMetadataItem.keySpace = AVMetadataKeySpaceCommon
        titleMetadataItem.key = AVMetadataCommonKeyTitle
        titleMetadataItem.value = mediaItem.title
        
        let artistMetadataItem = AVMutableMetadataItem()
        artistMetadataItem.keySpace = AVMetadataKeySpaceCommon
        artistMetadataItem.key = AVMetadataCommonKeyArtist
        artistMetadataItem.value = mediaItem.artist
        
        let albumNameMetadataItem = AVMutableMetadataItem()
        albumNameMetadataItem.keySpace = AVMetadataKeySpaceCommon
        albumNameMetadataItem.key = AVMetadataCommonKeyAlbumName
        albumNameMetadataItem.value = mediaItem.albumTitle
        
        let artworkMetadataItem = AVMutableMetadataItem()
        artworkMetadataItem.keySpace = AVMetadataKeySpaceCommon
        artworkMetadataItem.key = AVMetadataCommonKeyArtwork
        artworkMetadataItem.value = UIImageJPEGRepresentation(mediaItem.artwork.imageWithSize(kAlbumArtworkSize), 0.5)
        
        exportSession.outputFileType = AVFileTypeAppleM4A
        exportSession.metadata = [
            titleMetadataItem,
            artistMetadataItem,
            albumNameMetadataItem,
            artworkMetadataItem
        ]
    }
    
    func exportAsynchronouslyWithCompletionHandler(handler: (() -> Void)!) {
        exportSession.exportAsynchronouslyWithCompletionHandler(handler)
    }
    
    func cancelExport() {
        exportSession.cancelExport()
    }
    
}
