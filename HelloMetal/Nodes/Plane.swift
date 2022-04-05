//
//  Plane.swift
//  HelloMetal
//
//  Created by lxz on 2022/4/5.
//

import MetalKit

class Plane: Node {
    var vertices: [Vertex] = [
        Vertex(position: SIMD3<Float>(-1, 1, 0), color: SIMD4<Float>(1, 0, 0, 1)),
        Vertex(position: SIMD3<Float>(-1, -1, 0), color: SIMD4<Float>(0, 1, 0, 1)),
        Vertex(position: SIMD3<Float>(1, -1, 0), color: SIMD4<Float>(0, 0, 1, 1)),
        Vertex(position: SIMD3<Float>(1, 1, 0), color: SIMD4<Float>(1, 0, 1, 1)),
    ]
    let indices: [UInt16] = [
        0, 1, 2,
        2, 3, 0
    ]
    
    var vertexBuffer: MTLBuffer?
    var indexBuffer: MTLBuffer?
    
    struct Constants {
        var animateBy: Float = 0
    }
    
    var constants = Constants()
    
    var time: Float = 0
    
    init(device: MTLDevice) {
        super.init()
        buildBuffers(device: device)
    }
    
    private func buildBuffers(device: MTLDevice) {
        vertexBuffer = device.makeBuffer(bytes: vertices,
                                         length: vertices.count * MemoryLayout<Vertex>.size,
                                         options: [])
        indexBuffer = device.makeBuffer(bytes: indices,
                                        length: indices.count * MemoryLayout<UInt16>.size,
                                        options: [])
    }
    
    override func draw(commandEncoder: MTLRenderCommandEncoder) {
        guard
            let indexBuffer = indexBuffer,
            let vertexBuffer = vertexBuffer
        else {
            return
        }

        commandEncoder.setVertexBuffer(vertexBuffer,
                                        offset: 0,
                                        index: 0)

        commandEncoder.setVertexBytes(&constants,
                                       length: MemoryLayout<Constants>.stride,
                                       index: 1)
        
        commandEncoder.drawIndexedPrimitives(type: .triangle,
                                              indexCount: indices.count,
                                              indexType: .uint16,
                                              indexBuffer: indexBuffer,
                                              indexBufferOffset: 0)
    }
}
