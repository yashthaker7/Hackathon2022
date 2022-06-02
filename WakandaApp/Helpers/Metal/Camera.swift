//
//  Camera.swift
//
//  Created by Yash Thaker on 01/09/19.
//  Copyright © 2019 Yash Thaker. All rights reserved.
//

import Foundation
import AVFoundation
import Metal
import UIKit

protocol CameraDelegate: AnyObject {
    func newTexture(texture: Texture)
}

enum PhysicalCameraLocation {
    case backFacing
    case frontFacing
    
    func captureDevicePosition() -> AVCaptureDevice.Position {
        switch self {
        case .backFacing: return .back
        case .frontFacing: return .front
        }
    }
    
    func device() -> AVCaptureDevice? {
        let discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .unspecified)
        let devices = discoverySession.devices.compactMap { $0 }
        
        for case let device in devices {
            if (device.position == self.captureDevicePosition()) {
                return device
            }
        }
        
        return AVCaptureDevice.default(for: AVMediaType.video)
    }
}

struct CameraError: Error {
}

class Camera: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    var location: PhysicalCameraLocation {
        didSet {
            // TODO: Swap the camera locations, framebuffers as needed
        }
    }
    
    var videoTextureCache: CVMetalTextureCache?

    weak var delegate: CameraDelegate?
    let captureSession: AVCaptureSession
    let inputCamera: AVCaptureDevice!
    let videoInput: AVCaptureDeviceInput!
    let videoOutput: AVCaptureVideoDataOutput!
    var videoConnection: AVCaptureConnection!
    
    let stillImageOutput = AVCaptureStillImageOutput()
    
    let frameRenderingSemaphore = DispatchSemaphore(value: 1)
    let cameraProcessingQueue = DispatchQueue.global()
    let cameraFrameProcessingQueue = DispatchQueue(
        label: "com.yashThaker.cameraFrameProcessingQueue",
        attributes: [])
    
    init(sessionPreset: AVCaptureSession.Preset, location: PhysicalCameraLocation = .backFacing) throws {
        self.location = location
        
        self.captureSession = AVCaptureSession()
        self.captureSession.beginConfiguration()
        
        if let device = location.device() {
            self.inputCamera = device
        } else {
            self.inputCamera = nil
            self.videoInput = nil
            self.videoOutput = nil
            self.videoConnection = nil
            super.init()
            throw CameraError()
        }
        
        do {
            self.videoInput = try AVCaptureDeviceInput(device: inputCamera)
        } catch {
            self.videoInput = nil
            self.videoOutput = nil
            self.videoConnection = nil
            super.init()
            throw error
        }
        
        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        }
        
        // Add the video frame output
        videoOutput = AVCaptureVideoDataOutput()
        videoOutput.alwaysDiscardsLateVideoFrames = false
        
        videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: NSNumber(value: Int32(kCVPixelFormatType_32BGRA))]
        
        if (captureSession.canAddOutput(videoOutput)) {
            captureSession.addOutput(videoOutput)
        }
        
        videoConnection = videoOutput.connection(with: .video)
        videoConnection.videoOrientation = .portrait
        
        captureSession.sessionPreset = sessionPreset
        captureSession.commitConfiguration()
        
        stillImageOutput.outputSettings = [AVVideoCodecKey: AVVideoCodecType.jpeg]
        if captureSession.canAddOutput(stillImageOutput) {
            captureSession.addOutput(stillImageOutput)
        }
        
        super.init()
        
        if CVMetalTextureCacheCreate(kCFAllocatorDefault, nil, SharedMetalRendering.device, nil, &videoTextureCache) != kCVReturnSuccess {
            fatalError("Unable to allocate texture cache.")
        }
        
        videoOutput.setSampleBufferDelegate(self, queue: cameraProcessingQueue)
    }
    
    deinit {
        cameraFrameProcessingQueue.sync {
            self.stopCapture()
            self.videoOutput?.setSampleBufferDelegate(nil, queue: nil)
        }
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        guard (frameRenderingSemaphore.wait(timeout: DispatchTime.now()) == DispatchTimeoutResult.success) else { return }
        
        let cameraFrame = CMSampleBufferGetImageBuffer(sampleBuffer)!
        let bufferWidth = CVPixelBufferGetWidth(cameraFrame)
        let bufferHeight = CVPixelBufferGetHeight(cameraFrame)
        let currentTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
        
        CVPixelBufferLockBaseAddress(cameraFrame, CVPixelBufferLockFlags(rawValue: CVOptionFlags(0)))
        
        cameraFrameProcessingQueue.async {
            CVPixelBufferUnlockBaseAddress(cameraFrame, CVPixelBufferLockFlags(rawValue: CVOptionFlags(0)))
            
            let texture: Texture?
            
            var textureRef: CVMetalTexture? = nil
            let _ = CVMetalTextureCacheCreateTextureFromImage(kCFAllocatorDefault, self.videoTextureCache!, cameraFrame, nil, .bgra8Unorm, bufferWidth, bufferHeight, 0, &textureRef)
            if let concreteTexture = textureRef, let cameraTexture = CVMetalTextureGetTexture(concreteTexture) {
                texture = Texture(texture: cameraTexture, currentTime: currentTime)
            } else {
                texture = nil
            }
            
            if texture != nil {
                self.delegate?.newTexture(texture: texture!)
            }
            
            self.frameRenderingSemaphore.signal()
        }
    }
    
    func startCapture() {
        let _ = frameRenderingSemaphore.wait(timeout: DispatchTime.distantFuture)
        self.frameRenderingSemaphore.signal()
        
        if (!captureSession.isRunning) {
            captureSession.startRunning()
        }
    }
    
    func stopCapture() {
        if (captureSession.isRunning) {
            let _ = frameRenderingSemaphore.wait(timeout: DispatchTime.distantFuture)
            
            captureSession.stopRunning()
            self.frameRenderingSemaphore.signal()
        }
    }
    
    var orientation = UIApplication.shared.statusBarOrientation
    
    func capureImage(_ completion: @escaping(UIImage) -> ()) {
        guard let connection = stillImageOutput.connection(with: .video) else { return }
        stillImageOutput.captureStillImageAsynchronously(from: connection) { sampleBuffer, error in
            guard let sampleBuffer = sampleBuffer, error == nil else {
                print(error ?? "Unknown error")
                return
            }
            guard let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer),
                  let dataProvider = CGDataProvider(data: imageData as CFData),
                  let cgImageRef = CGImage(jpegDataProviderSource: dataProvider, decode: nil, shouldInterpolate: true, intent: .defaultIntent) else {
                      print("unable to capture image")
                      return
                  }
            
            var image: UIImage?
            
            switch self.orientation {
            case .portrait:
                image = UIImage(cgImage: cgImageRef, scale: 1.0, orientation: .right)
            case .landscapeRight:
                image = UIImage(cgImage: cgImageRef, scale: 1.0, orientation: .up)
            case .landscapeLeft:
                image = UIImage(cgImage: cgImageRef, scale: 1.0, orientation: .down)
            case .portraitUpsideDown:
                image = UIImage(cgImage: cgImageRef, scale: 1.0, orientation: .left)
            default:
                fatalError("Unexpected orientation")
            }
            
            guard image != nil else {
                print("unable to create UIImage")
                return
            }
            
            DispatchQueue.main.async {
                if let image = image {
                    DispatchQueue.main.async { completion(image) }
                }
            }
        }
    }
    
}
