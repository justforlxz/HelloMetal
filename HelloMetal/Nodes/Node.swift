//
//  Node.swift
//  HelloMetal
//
//  Created by lxz on 2022/4/5.
//

import MetalKit

class Node {
    var pipelineState: MTLRenderPipelineState!
    var samplerState: MTLSamplerState?

    init() {
    }

    func draw(commandEncoder: MTLRenderCommandEncoder) {}
}
