//
//  Renderer.swift
//  HelloMetal
//
//  Created by lxz on 2022/4/3.
//


import UIKit
import MetalKit

enum Colors {
    static let wenderlichGreen = MTLClearColor(red: 0.0,
                                               green: 0.4,
                                               blue: 0.21,
                                               alpha: 1.0)
}

class Renderer: NSObject {
    let device: MTLDevice
    var scene: Scene?
    let commandQueue: MTLCommandQueue
    init(device: MTLDevice) {
        self.device = device
        commandQueue = device.makeCommandQueue()!
        super.init()
     }
}

extension Renderer: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
    }
    func draw(in view: MTKView) {
        guard let drawable = view.currentDrawable,
              let scene = scene,
              let commandBuffer = commandQueue.makeCommandBuffer(),
              let descriptor = view.currentRenderPassDescriptor,
              let commandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor)
        else {
            return
        }
        
        let deltaTime = 1 / Float(view.preferredFramesPerSecond)
        
        scene.render(commandEncoder: commandEncoder, deltaTime: deltaTime)

        commandEncoder.endEncoding()
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}

