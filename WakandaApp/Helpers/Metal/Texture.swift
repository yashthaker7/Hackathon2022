//
//  Texture.swift
//
//  Created by Yash Thaker on 01/09/19.
//  Copyright © 2019 Yash Thaker. All rights reserved.
//

import Foundation
import CoreMedia
import MetalKit

class Texture {
    
    let texture: MTLTexture
    
    let currentTime: CMTime
    
    init(texture: MTLTexture, currentTime: CMTime) {
        self.texture = texture
        self.currentTime = currentTime
    }
}
