//
//  MovieInput.swift
//
//  Created by Yash Thaker on 01/09/19.
//  Copyright © 2019 Yash Thaker. All rights reserved.
//

import AVFoundation

protocol MovieInputDelegate: class {
    func newTexture(texture: Texture)
}

class MovieInput {
    
    let videoUrl: URL
    
    let player = AVPlayer()
    
    lazy var playerItemVideoOutput: AVPlayerItemVideoOutput = {
        let attributes = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)]
        return AVPlayerItemVideoOutput(pixelBufferAttributes: attributes)
    }()
    
    lazy var displayLink: CADisplayLink = {
        let dl = CADisplayLink(target: self, selector: #selector(readBuffer(_:)))
        dl.add(to: .current, forMode: .default)
        dl.isPaused = true
        return dl
    }()
    
    var videoTextureCache: CVMetalTextureCache?
    
    weak var delegate: MovieInputDelegate?
    
    init(videoUrl: URL) {
        self.videoUrl = videoUrl
        
        let playerItem = AVPlayerItem(url: self.videoUrl)
        playerItem.add(self.playerItemVideoOutput)
        
        player.replaceCurrentItem(with: playerItem)
        
        if CVMetalTextureCacheCreate(kCFAllocatorDefault, nil, SharedMetalRendering.device, nil, &videoTextureCache) != kCVReturnSuccess {
            fatalError("Unable to allocate texture cache.")
        }
    }
    
    @objc func readBuffer(_ sender: CADisplayLink) {
        var currentTime = CMTime.invalid
        let nextVSync = sender.timestamp + sender.duration
        currentTime = playerItemVideoOutput.itemTime(forHostTime: nextVSync)

        if playerItemVideoOutput.hasNewPixelBuffer(forItemTime: currentTime),
            let pixelBuffer = playerItemVideoOutput.copyPixelBuffer(forItemTime: currentTime, itemTimeForDisplay: nil) {
            
            var cvTextureRef: CVMetalTexture?
            
            let bufferWidth = CVPixelBufferGetWidth(pixelBuffer)
            let bufferHeight = CVPixelBufferGetHeight(pixelBuffer)
            
            CVMetalTextureCacheCreateTextureFromImage(kCFAllocatorDefault, self.videoTextureCache!, pixelBuffer, nil, .bgra8Unorm, bufferWidth, bufferHeight, 0, &cvTextureRef)
            
            if let cvTexture = cvTextureRef, let outputTexture = CVMetalTextureGetTexture(cvTexture) {
                let texture = Texture(texture: outputTexture, currentTime: currentTime)
                delegate?.newTexture(texture: texture)
            }
        }
    }
    
    func start() {
        displayLink.isPaused = false
        player.play()
    }
    
    func pause() {
        displayLink.isPaused = true
        player.pause()
    }
    
    deinit {
        displayLink.isPaused = true
        displayLink.remove(from: .current, forMode: .default)
        print("MovieInput deinit.")
    }

}
