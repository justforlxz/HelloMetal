//
//  Plane.swift
//  HelloMetal
//
//  Created by lxz on 2022/4/5.
//

import MetalKit

class Plane: Node {
    var vertices: [Vertex] = [
        Vertex(position: SIMD3<Float>(-1, 1, 0),
               color: SIMD4<Float>(1, 0, 0, 1),
               texture: SIMD2<Float>(1, 0)),
        Vertex(position: SIMD3<Float>(-1, -1, 0),
               color: SIMD4<Float>(0, 1, 0, 1),
               texture: SIMD2<Float>(1, 1)),
        Vertex(position: SIMD3<Float>(1, -1, 0),
               color: SIMD4<Float>(0, 0, 1, 1),
               texture: SIMD2<Float>(0, 1)),
        Vertex(position: SIMD3<Float>(1, 1, 0),
               color: SIMD4<Float>(1, 0, 1, 1),
               texture: SIMD2<Float>(0, 0)),
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
    var texture: MTLTexture?
    var samplerState: MTLSamplerState?
    
    init(device: MTLDevice) {
        super.init()
        buildBuffers(device: device)
        buildPipelineState(device: device)
        buildSamplerState(device: device)
    }

    init(device: MTLDevice, imageName: String) {
        super.init()
        if let texture = setTexture(device: device, imageName: imageName) {
            self.texture = texture
            fragmentFunctionName = "textured_fragment"
        }

        buildBuffers(device: device)
        buildPipelineState(device: device)
        buildSamplerState(device: device)
    }

    // Renderable
    var pipelineState: MTLRenderPipelineState!
    var fragmentFunctionName: String = "fragment_shader"
    var vertexFunctionname: String = "vertex_shader"
    
    var vertexDescriptor: MTLVertexDescriptor {
        let vertexDescriptor = MTLVertexDescriptor()
        
        // position
        vertexDescriptor.attributes[0].format = .float3
        vertexDescriptor.attributes[0].offset = 0
        vertexDescriptor.attributes[0].bufferIndex = 0
        
        // color
        vertexDescriptor.attributes[1].format = .float4
        vertexDescriptor.attributes[1].offset = MemoryLayout<SIMD3<Float>>.stride
        vertexDescriptor.attributes[1].bufferIndex = 0

// texture
        vertexDescriptor.attributes[2].format = .float2
        vertexDescriptor.attributes[2].offset = MemoryLayout<SIMD3<Float>>.stride + MemoryLayout<SIMD4<Float>>.stride
        vertexDescriptor.attributes[2].bufferIndex = 0
        
        vertexDescriptor.layouts[0].stride = MemoryLayout<Vertex>.stride
        
        return vertexDescriptor
    }
    
    private func buildPipelineState(device: MTLDevice) {
        let library = device.makeDefaultLibrary()
        let vertexFunction = library?.makeFunction(name: vertexFunctionname)
        let fragmentFunction = library?.makeFunction(name: fragmentFunctionName)
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        pipelineDescriptor.vertexDescriptor = vertexDescriptor
        pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
    
        do {
            pipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        } catch let error as NSError {
            print("error: \(error.localizedDescription)")
        }
    }
    
    private func buildBuffers(device: MTLDevice) {
        vertexBuffer = device.makeBuffer(bytes: vertices,
                                         length: vertices.count * MemoryLayout<Vertex>.size,
                                         options: [])
        indexBuffer = device.makeBuffer(bytes: indices,
                                        length: indices.count * MemoryLayout<UInt16>.size,
                                        options: [])
    }
    
    private func buildSamplerState(device: MTLDevice) {
        let descriptor = MTLSamplerDescriptor()
        descriptor.minFilter = .linear
        descriptor.magFilter = .linear
        samplerState = device.makeSamplerState(descriptor: descriptor)
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
        commandEncoder.setFragmentTexture(texture, index: 0)
        commandEncoder.drawIndexedPrimitives(type: .triangle,
                                              indexCount: indices.count,
                                              indexType: .uint16,
                                              indexBuffer: indexBuffer,
                                              indexBufferOffset: 0)
    }
}

extension Plane: Renderable {
}

extension Plane: Texturable {
}
