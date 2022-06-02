//
//  RenderView.swift
//
//  Created by Yash Thaker on 01/09/19.
//  Copyright © 2019 Yash Thaker. All rights reserved.
//

import MetalKit

class RenderView: MTKView {
    
    private var currentTexture: Texture?
    private var renderPipelineState: MTLRenderPipelineState!
    
    override init(frame frameRect: CGRect, device: MTLDevice?) {
        super.init(frame: frameRect, device: SharedMetalRendering.device)
        
        commonInit()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        
        commonInit()
    }
    
    private func commonInit() {
        framebufferOnly = false
        autoResizeDrawable = true
        
        device = SharedMetalRendering.device
        
        self.renderPipelineState = SharedMetalRendering.basicShader
        
        contentMode = .scaleAspectFill
        enableSetNeedsDisplay = false
        isPaused = true
    }
    
    func newTextureAvailable(_ texture: Texture) {
        self.drawableSize = CGSize(width: texture.texture.width, height: texture.texture.height)
        currentTexture = texture
        self.draw()
    }
    
    override func draw(_ rect: CGRect) {
        if let currentDrawable = self.currentDrawable,
            let currentTexture = self.currentTexture,
            let commandBuffer = SharedMetalRendering.commandQueue.makeCommandBuffer() {
            
            let renderPassDescriptor = MTLRenderPassDescriptor()
            renderPassDescriptor.colorAttachments[0].texture = currentDrawable.texture
            renderPassDescriptor.colorAttachments[0].loadAction = .clear
            renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(red: 1.0, green: 0.0, blue: 1.0, alpha: 1.0)
            
            guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else {
                fatalError("Could not create render encoder")
            }
            renderEncoder.setRenderPipelineState(renderPipelineState)
            renderEncoder.setVertexBuffer(SharedMetalRendering.vertexBuffer, offset: 0, index: 0)
            renderEncoder.setVertexBuffer(SharedMetalRendering.textureBuffer, offset: 0, index: 1)
            renderEncoder.setFragmentTexture(currentTexture.texture, index: 0)
            
            var time = Float(currentTexture.currentTime.seconds)
            let timeBuffer = SharedMetalRendering.device.makeBuffer(bytes: &time,
                                                                          length: MemoryLayout<Float>.size,
                                                                          options: [])
            renderEncoder.setFragmentBuffer(timeBuffer, offset: 0, index: 2)
            
            renderEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)
            renderEncoder.endEncoding()
            
            commandBuffer.present(currentDrawable)
            commandBuffer.commit()
        }
    }
    
    deinit {
        print("RenderView deinit")
    }
    
}

