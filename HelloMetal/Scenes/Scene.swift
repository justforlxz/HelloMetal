//
//  Scene.swift
//  HelloMetal
//
//  Created by lxz on 2022/4/5.
//

import MetalKit

class Scene {
    var childNodes: [Node]
    init(device: MTLDevice, size: CGSize) {
        childNodes = [Node]()
    }
    func add(childNodes: Node) {
        self.childNodes += [childNodes]
    }

    func render(commandEncoder: MTLRenderCommandEncoder, deltaTime: Float) {
        for node in childNodes {
            guard
                  let pipelineState = node.pipelineState
            else {
                continue
            }
            commandEncoder.setFragmentSamplerState(node.samplerState, index: 0)
            commandEncoder.setRenderPipelineState(pipelineState)
            node.draw(commandEncoder: commandEncoder)
        }
    }
}
