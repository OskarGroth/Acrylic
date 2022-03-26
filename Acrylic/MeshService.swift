//
//  MeshService.swift
//  Acrylic
//
//  Created by Ethan Lipnik on 10/23/21.
//

import Combine
import MeshKit
import UIKit
import RandomColor

class MeshService: ObservableObject {
    @Published var colors: [MeshNode.Color] = []
    @Published var width: Int = 3
    @Published var height: Int = 3
    @Published var subdivsions: Int = 18
    @Published var isRenderingAsWireframe: Bool = false
    
    @Published var selectedPoint: Point? = nil
    @Published var isExporting: Bool = false
    
    struct Point: Equatable {
        var x: Int
        var y: Int
        
        var nodePoint: (x: Int, y: Int) {
            return (x, y)
        }
    }
    
    func render(resolution: CGSize = CGSize(width: 1024, height: 1024)) -> UIImage {
        let scene = MeshScene()
        scene.create(colors, width: width, height: height, subdivisions: subdivsions)
        
        return scene.generate(size: resolution)
    }
    
    func generate(pallete hues: RandomColor.Hue...,
                  luminosity: RandomColor.Luminosity = .bright,
                  shouldRandomizePointLocations: Bool = true,
                  positionMultiplier: Float = 0.6) {
        var colors: [MeshNode.Color] = []
        
        let newColors: [UIColor] = hues.flatMap({ randomColors(count: Int(ceil(Float(width * height) / Float(hues.count))), hue: $0, luminosity: luminosity) })
        
        for x in 0..<width {
            for y in 0..<height {
                autoreleasepool {
                    var location = (Float(x), Float(y))
                    
                    if (x != 0 && x != width - 1 && y != 0 && y != height - 1) && shouldRandomizePointLocations && positionMultiplier != 0 {
                        location = (Float.random(in: (Float(x) - positionMultiplier)..<(Float(x) + positionMultiplier)), Float.random(in: (Float(y) - positionMultiplier)..<(Float(y) + positionMultiplier)))
                    }
                    
                    var colorIndex: Int = 0
                    let xColorIndex = (x * width) + y
                    let yColorIndex = (y * height) + x
                    
                    if xColorIndex < newColors.count {
                        colorIndex = xColorIndex
                    } else if yColorIndex < newColors.count {
                        colorIndex = yColorIndex
                    }
                    
                    colors.append(.init(point: (x, y), location: location, color: newColors[min(colorIndex, newColors.count - 1)], tangent: (2, 2)))
                }
            }
        }
        
        self.colors = colors
    }
    
    func randomizePositions(positionMultiplier: Float = 0.6) {
        for i in 0..<colors.count {
            let x = colors[i].point.x
            let y = colors[i].point.y
            
            if (x != 0 && x != width - 1 && y != 0 && y != height - 1) && positionMultiplier != 0 {
                colors[i].location = (Float.random(in: (Float(x) - positionMultiplier)..<(Float(x) + positionMultiplier)), Float.random(in: (Float(y) - positionMultiplier)..<(Float(y) + positionMultiplier)))
            }
        }
    }
}

extension Hue {
    static var allCases: [Hue] {
        get {
            return [
                .blue,
                .orange,
                .yellow,
                .green,
                .pink,
                .purple,
                .red,
                .monochrome
            ]
        }
    }
    
    static func randomPalette(includesMonochrome: Bool = false) -> Hue {
        var hues = allCases
        
        if includesMonochrome {
            hues.removeLast()
        }
        
        return hues.randomElement() ?? .monochrome
    }
}
