//
//  GameScene.swift
//  HelloMetal
//
//  Created by lxz on 2022/4/5.
//

import MetalKit

class GameScene: Scene {
    var quad: Plane
    override init(device: MTLDevice, size: CGSize) {
        quad = Plane(device: device)
        super.init(device: device, size: size)        
    }
}
