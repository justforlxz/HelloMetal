//
//  Plane.swift
//  HelloMetal
//
//  Created by lxz on 2022/4/5.
//

import MetalKit

class Plane: Node {
    var positionVertices: [simd_float4] = [
        simd_float4(-1, 1, 0, 1),
        simd_float4(-1, -1, 0, 1),
        simd_float4(1, -1, 0, 1),
        simd_float4(1, 1, 0, 1),
    ]
    
    var colorVertices: [simd_float4] = [
        simd_float4(1, 0, 0, 1),
        simd_float4(0, 1, 0, 1),
        simd_float4(0, 0, 1, 1),
        simd_float4(1, 0, 1, 1),
    ]
    
    var textureVertices: [simd_float2] = [
        simd_float2(0, 1),
        simd_float2(0, 0),
        simd_float2(1, 0),
        simd_float2(1, 1),
    ]
    
    var positionBuffer: MTLBuffer?
    var colorBuffer: MTLBuffer?
    var textureBuffer: MTLBuffer?

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
        vertexDescriptor.attributes[0].format = .float4
        vertexDescriptor.attributes[0].offset = 0
        vertexDescriptor.attributes[0].bufferIndex = 0

        // color
        vertexDescriptor.attributes[1].format = .float4
        vertexDescriptor.attributes[1].offset = 0
        vertexDescriptor.attributes[1].bufferIndex = 1

        // texture
        vertexDescriptor.attributes[2].format = .float2
        vertexDescriptor.attributes[2].offset = 0
        vertexDescriptor.attributes[2].bufferIndex = 2

        vertexDescriptor.layouts[0].stride = MemoryLayout<simd_float4>.stride
        vertexDescriptor.layouts[1].stride = MemoryLayout<simd_float4>.stride
        vertexDescriptor.layouts[2].stride = MemoryLayout<simd_float2>.stride

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
        positionBuffer = device.makeBuffer(bytes: positionVertices,
                                          length: positionVertices.count * MemoryLayout<simd_float4>.size,
                                          options: [])
        colorBuffer = device.makeBuffer(bytes: colorVertices,
                                          length: colorVertices.count * MemoryLayout<simd_float4>.size,
                                          options: [])
        textureBuffer = device.makeBuffer(bytes: textureVertices,
                                          length: textureVertices.count * MemoryLayout<simd_float2>.size,
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
            let vertex1Buffer = positionBuffer,
            let vertex2Buffer = colorBuffer,
            let vertex3Buffer = textureBuffer
        else {
            return
        }

        //commandEncoder.setTriangleFillMode(.lines)

        commandEncoder.setVertexBuffer(vertex1Buffer,
                                        offset: 0,
                                        index: 0)
        commandEncoder.setVertexBuffer(vertex2Buffer,
                                        offset: 0,
                                        index: 1)
        commandEncoder.setVertexBuffer(vertex3Buffer,
                                        offset: 0,
                                        index: 2)

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
