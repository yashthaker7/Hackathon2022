//
//  MetalRendering.swift
//
//  Created by Yash Thaker on 01/09/19.
//  Copyright © 2019 Yash Thaker. All rights reserved.
//

import Foundation
import Metal

let SharedMetalRendering = MetalRendering()

class MetalRendering {

    let device: MTLDevice
    let commandQueue: MTLCommandQueue
    let defaultLibrary: MTLLibrary
    
    let vertexData: [Float] = [-1.0, 1.0, 1.0, 1.0, -1.0, -1.0, 1.0, -1.0]
    let vertexBuffer: MTLBuffer
    
    let textureData: [Float] = [0.0, 0.0, 1.0, 0.0, 0.0, 1.0, 1.0, 1.0]
    let textureBuffer: MTLBuffer
    
    lazy var basicShader: MTLRenderPipelineState = {
        return generateRenderPipelineState(fragmentFunctionName: "passthroughFragment")
    }()
    
    lazy var luminanceShader: MTLRenderPipelineState = {
        return generateRenderPipelineState(fragmentFunctionName: "luminanceFragment")
    }()
    
    lazy var VHSShader: MTLRenderPipelineState = {
        return generateRenderPipelineState(fragmentFunctionName: "VHSFragment")
    }()
    
    lazy var glitchShader: MTLRenderPipelineState = {
        return generateRenderPipelineState(fragmentFunctionName: "glitchFragment")
    }()
    
    init() {
        guard let device = MTLCreateSystemDefaultDevice() else { fatalError("Could not create Metal Device") }
        self.device = device
        
        guard let queue = self.device.makeCommandQueue() else { fatalError("Could not create command queue") }
        self.commandQueue = queue
        
        guard let library = device.makeDefaultLibrary() else { fatalError("Could not create default library") }
        self.defaultLibrary = library
        
        self.vertexBuffer = device.makeBuffer(bytes: vertexData,
                                         length: vertexData.count * MemoryLayout.size(ofValue: vertexData[0]),
                                         options: [])!
        
        self.textureBuffer = device.makeBuffer(bytes: textureData,
                                               length: textureData.count * MemoryLayout.size(ofValue: textureData[0]),
                                               options: [])!
    }
    
    func generateRenderPipelineState(vertexFunctionName: String = "oneInputVertex", fragmentFunctionName: String) -> MTLRenderPipelineState {
        guard let vertexFunction = defaultLibrary.makeFunction(name: vertexFunctionName) else {
            fatalError("could not compile vertex function \(vertexFunctionName)")
        }
        
        guard let fragmentFunction = defaultLibrary.makeFunction(name: fragmentFunctionName) else {
            fatalError("could not compile fragment function \(fragmentFunctionName)")
        }
        
        let descriptor = MTLRenderPipelineDescriptor()
        descriptor.colorAttachments[0].pixelFormat = MTLPixelFormat.bgra8Unorm
        descriptor.vertexFunction = vertexFunction
        descriptor.fragmentFunction = fragmentFunction
        
        return try! device.makeRenderPipelineState(descriptor: descriptor)
    }
    
}


