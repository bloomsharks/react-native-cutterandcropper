
import AVFoundation
import Foundation
import UIKit

final class VideoTrimmer {
    typealias TrimCompletion = (Error?,URL?,CGSize?) -> ()
    typealias TrimPoints = [(CMTime, CMTime)]
    
//    func verifyPresetForAsset(preset: String, asset: AVAsset) -> Bool {
//        let compatiblePresets = AVAssetExportSession.exportPresets(compatibleWith: asset)
//        let filteredPresets = compatiblePresets.filter { $0 == preset }
//        return filteredPresets.count > 0 || preset == AVAssetExportPresetPassthrough
//    }

   private func removeFileAtURLIfExists(url: URL) {
        
        let fileManager = FileManager.default
        
        guard fileManager.fileExists(atPath: url.path) else { return }
        
        do {
            try fileManager.removeItem(at: url)
        }
        catch let error {
            print("TrimVideo - Couldn't remove existing destination file: \(String(describing: error))")
        }
    }
    
    func trimVideo(sourceURL: URL, destinationURL: URL, trimPoints: TrimPoints, completion: TrimCompletion?) {
        
        guard sourceURL.isFileURL else { return }
        guard destinationURL.isFileURL else { return }
        
        let options = [
            AVURLAssetPreferPreciseDurationAndTimingKey: true
        ]
        
        let asset = AVURLAsset(url: sourceURL, options: options)
        let preferredPreset = AVAssetExportPresetMediumQuality
        
       // if  verifyPresetForAsset(preset: preferredPreset, asset: asset) {
            
            let composition = AVMutableComposition()
        
        guard let assetVideoTrack: AVAssetTrack = asset.tracks(withMediaType: .video).first else { return }
       
        let videoCompTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: CMPersistentTrackID())
        
         let assetAudioTrack: AVAssetTrack? = asset.tracks(withMediaType: .audio).first
        var audioCompTrack: AVMutableCompositionTrack?
        if assetAudioTrack != nil {
         audioCompTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: CMPersistentTrackID())
        }
          
           
            
            videoCompTrack!.preferredTransform = assetVideoTrack.preferredTransform
            
            let videoSize : CGSize = assetVideoTrack.naturalSize.applying(assetVideoTrack.preferredTransform)
            
            var accumulatedTime = CMTime.zero
            for (startTimeForCurrentSlice, endTimeForCurrentSlice) in trimPoints {
                let durationOfCurrentSlice = CMTimeSubtract(endTimeForCurrentSlice, startTimeForCurrentSlice)
                let timeRangeForCurrentSlice = CMTimeRangeMake(start: startTimeForCurrentSlice, duration: durationOfCurrentSlice)
                
                do {
                    try videoCompTrack!.insertTimeRange(timeRangeForCurrentSlice, of: assetVideoTrack, at: accumulatedTime)
                if let assetAudioTrack = assetAudioTrack{
                    try audioCompTrack!.insertTimeRange(timeRangeForCurrentSlice, of: assetAudioTrack, at: accumulatedTime)
                      }
                    accumulatedTime = CMTimeAdd(accumulatedTime, durationOfCurrentSlice)
                }
                catch let compError {
                    print("TrimVideo: error during composition: \(compError)")
                    completion?(compError,nil,nil)
                }
            }
            
            guard let exportSession = AVAssetExportSession(asset: composition, presetName: preferredPreset) else { return }
            
            exportSession.outputURL = destinationURL as URL
            exportSession.outputFileType = AVFileType.mp4
            exportSession.shouldOptimizeForNetworkUse = true
            
            removeFileAtURLIfExists(url: destinationURL as URL)
            
            exportSession.exportAsynchronously {
                completion?(exportSession.error,destinationURL,videoSize)
            }
        }
//        else {
//            print("TrimVideo - Could not find a suitable export preset for the input video")
//            let error = NSError(domain: "com.bighug.ios", code: -1, userInfo: nil)
//            completion?(error,nil,nil)
//        }
//    }
}
