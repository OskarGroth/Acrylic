//
//  MeshService.swift
//  Acrylic
//
//  Created by Ethan Lipnik on 10/23/21.
//

import Combine
import MeshKit
import UIKit

class MeshService: ObservableObject {
    @Published var colors: [MeshNode.Color] = []
    @Published var width: Int = 3
    @Published var height: Int = 3
    @Published var subdivsions: Int = 18
    @Published var isRenderingAsWireframe: Bool = false
    
    @Published var isExporting: Bool = false
    
    func render(resolution: CGSize = CGSize(width: 4096, height: 4096), completion: @escaping (UIImage) -> Void) {
        let view = MeshView()
        view.create(colors, width: width, height: height, subdivisions: subdivsions)
        view.isHidden = true
        
        completion(view.generate(size: resolution))
    }
}
