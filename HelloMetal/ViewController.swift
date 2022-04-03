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
        renderer = Renderer(device: metalView.device!)
        metalView.clearColor = Colors.wenderlichGreen
        metalView.delegate = renderer
    }
}

