//
//  ViewController.swift
//  HelloMetal
//
//  Created by lxz on 2022/4/3.
//

import UIKit
import MetalKit

class ViewController: UIViewController {
    var metalView: MTKView {
        return view as! MTKView
    }
    var renderer: Renderer!
    override func viewDidLoad() {
        super.viewDidLoad()
        metalView.device = MTLCreateSystemDefaultDevice()
        guard let device = metalView.device else {
            fatalError("Device not created. Run on a physic device!")
        }
        renderer = Renderer(device: device)
        renderer.scene = GameScene(device: device, size: CGSize(width: 300, height: 300))
        metalView.clearColor = Colors.wenderlichGreen
        metalView.delegate = renderer
    }
}

