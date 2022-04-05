//
//  Texturable.swift
//  HelloMetal
//
//  Created by lxz on 2022/4/5.
//

import MetalKit
protocol Texturable {
    var texture: MTLTexture? { get set }
}

extension Texturable {
    func setTexture(device: MTLDevice, imageName: String) -> MTLTexture? {
        let textureLoader = MTKTextureLoader(device: device)

        var texture: MTLTexture? = nil

        // change direction
        let textureLoaderOptions: [MTKTextureLoader.Option: Any] = [.origin: MTKTextureLoader.Origin.bottomLeft]
        //let textureLoaderOptions: [MTKTextureLoader.Option: Any] = [:]
        if let textureURL = Bundle.main.url(forResource: imageName, withExtension: nil) {
            do {
                texture = try textureLoader.newTexture(URL: textureURL, options: textureLoaderOptions)
            } catch {
                print("texture not created")
            }
        }
        return texture
    }
}
