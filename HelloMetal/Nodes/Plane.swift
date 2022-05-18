//
//  Plane.swift
//  HelloMetal
//
//  Created by lxz on 2022/4/5.
//

import MetalKit

class Plane: Node {
    var vertexData: [Vertex] = [
        Vertex(position: simd_float3(-1, 1, 0), color:simd_float4(1,0,0,1), texture: simd_float2(0,1)),
        Vertex(position: simd_float3(-1, -1, 0), color: simd_float4(0,1,0,1), texture: simd_float2(0,0)),
        Vertex(position: simd_float3(1, -1, 0), color: simd_float4(0,0,0,1), texture: simd_float2(1,0)),
        Vertex(position: simd_float3(1, 1, 0), color: simd_float4(1,1,0,1), texture: simd_float2(1,1)),
    ]

    var vertexBuffer: MTLBuffer?

    let indices: [UInt16] = [
        0, 1, 2,
        2, 3, 0
    ]
    var indexBuffer: MTLBuffer?

    struct Constants {
        var animateBy: Float = 0
    }

    var constants = Constants()
    var time: Float = 0
    var texture: MTLTexture?

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
    var fragmentFunctionName: String = "fragment_shader"
    var vertexFunctionname: String = "vertex_shader"

    var vertexDescriptor: MTLVertexDescriptor {
        let vertexDescriptor = MTLVertexDescriptor()

        var offset = 0

        // position
        vertexDescriptor.attributes[0].format = .float3
        vertexDescriptor.attributes[0].offset = offset
        vertexDescriptor.attributes[0].bufferIndex = 0

        offset += MemoryLayout<SIMD3<Float>>.stride

        // color
        vertexDescriptor.attributes[1].format = .float4
        vertexDescriptor.attributes[1].offset = offset
        vertexDescriptor.attributes[1].bufferIndex = 0

        offset += MemoryLayout<SIMD4<Float>>.stride

        // texture
        vertexDescriptor.attributes[2].format = .float2
        vertexDescriptor.attributes[2].offset = offset
        vertexDescriptor.attributes[2].bufferIndex = 0

        offset += MemoryLayout<SIMD2<Float>>.stride

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
        indexBuffer = device.makeBuffer(bytes: indices,
                                        length: indices.count * MemoryLayout<UInt16>.size,
                                        options: [])
        vertexBuffer = device.makeBuffer(bytes: vertexData,
                                       length: vertexData.count * MemoryLayout<Vertex>.stride,options:[])
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

        commandEncoder.setVertexBuffer(vertexBuffer,offset:0,index:0)

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
