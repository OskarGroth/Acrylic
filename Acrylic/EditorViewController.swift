//
//  EditorViewController.swift
//  Acrylic
//
//  Created by Ethan Lipnik on 10/23/21.
//

import UIKit
import MeshKit
import Combine
import SwiftUI

class EditorViewController: UIViewController {
    
    lazy var meshView: MeshView = {
        let view = MeshView()
        
        view.layer.cornerRadius = 30
        view.layer.cornerCurve = .continuous
        
        view.subviews.forEach({ $0.layer.cornerRadius = 30; $0.layer.cornerCurve = .continuous; $0.layer.masksToBounds = true })
        
        view.layer.shadowOffset = CGSize(width: 0, height: 10)
        view.layer.shadowRadius = 30
        view.layer.shadowOpacity = 0.4
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    lazy var backgroundView: SBAVisualEffectView = {
        let view = SBAVisualEffectView(blurStyle: .systemUltraThinMaterial)
        
        view.frame = self.view.bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        return view
    }()
    
    lazy var grabbersView: GrabbersView = {
        let view = GrabbersView()
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    lazy var meshService: MeshService! = {
        (view.window?.windowScene?.delegate as? SceneDelegate)?.meshService
    }()
    
    private var cancellables: Set<AnyCancellable> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        view.backgroundColor = UIColor.systemBackground
        
#if targetEnvironment(macCatalyst)
        view.addSubview(backgroundView)
#endif
        view.addSubview(meshView)
        meshView.addSubview(grabbersView)
        
        NSLayoutConstraint.activate([
            meshView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            meshView.leadingAnchor.constraint(equalTo: view.readableContentGuide.leadingAnchor),
            meshView.trailingAnchor.constraint(equalTo: view.readableContentGuide.trailingAnchor),
            meshView.widthAnchor.constraint(equalTo: meshView.heightAnchor),
            meshView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            
            grabbersView.leadingAnchor.constraint(equalTo: meshView.leadingAnchor),
            grabbersView.trailingAnchor.constraint(equalTo: meshView.trailingAnchor),
            grabbersView.bottomAnchor.constraint(equalTo: meshView.bottomAnchor),
            grabbersView.topAnchor.constraint(equalTo: meshView.topAnchor)
        ])
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        meshService.$colors
            .sink { [weak self] colors in
                guard let self = self else { return }
                self.meshView.create(colors, width: self.meshService.width, height: self.meshService.height, subdivisions: self.meshService.subdivsions)
                
                self.grabbersView.setPoints(colors, width: self.meshService.width, height: self.meshService.height)
            }
            .store(in: &cancellables)
        
        meshService.$subdivsions
            .sink { [weak self] subdivions in
                guard let self = self else { return }
                self.meshView.create(self.meshService.colors, width: self.meshService.width, height: self.meshService.height, subdivisions: subdivions)
            }
            .store(in: &cancellables)
        
        meshService.$isRenderingAsWireframe
            .sink { [weak self] isRenderingAsWireframe in
                self?.meshView.debugOptions = isRenderingAsWireframe ? [.renderAsWireframe] : []
            }
            .store(in: &cancellables)
        
        if meshService.colors.isEmpty {
            meshService.colors = [
                .init(point: (0, 0), location: (0, 0), color: UIColor(red: 0.149, green: 0.275, blue: 0.325, alpha: 1.000)),
                .init(point: (0, 1), location: (0, 1), color: UIColor(red: 0.157, green: 0.447, blue: 0.443, alpha: 1.000)),
                .init(point: (0, 2), location: (0, 2), color: UIColor(red: 0.165, green: 0.616, blue: 0.561, alpha: 1.000)),
                
                .init(point: (1, 0), location: (1, 0), color: UIColor(red: 0.541, green: 0.694, blue: 0.490, alpha: 1.000)),
                .init(point: (1, 1), location: (1, 1), color: UIColor(red: 0.541, green: 0.694, blue: 0.490, alpha: 1.000)),
                .init(point: (1, 2), location: (1, 2), color: UIColor(red: 0.914, green: 0.769, blue: 0.416, alpha: 1.000)),
                
                .init(point: (2, 0), location: (2, 0), color: UIColor(red: 0.957, green: 0.635, blue: 0.380, alpha: 1.000)),
                .init(point: (2, 1), location: (2, 1), color: UIColor(red: 0.933, green: 0.537, blue: 0.349, alpha: 1.000)),
                .init(point: (2, 2), location: (2, 2), color: UIColor(red: 0.906, green: 0.435, blue: 0.318, alpha: 1.000)),
            ]
        }
    }
}

struct EditorView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> EditorViewController {
        return .init()
    }
    
    func updateUIViewController(_ uiViewController: EditorViewController, context: Context) {
        
    }
}

class GrabbersView: UIView {
    
    private(set) lazy var grabberViews: [GrabberView] = []
    private(set) var width: Int = 0
    private(set) var height: Int = 0
    
    func setPoints(_ colors: [MeshNode.Color], width: Int, height: Int) {
        self.width = width
        self.height = height
        
        if subviews.isEmpty {
            grabberViews = colors.map({ createGrabber($0) })
            grabberViews.forEach(addSubview)
        } else {
            grabberViews.forEach { [bounds] grabber in
                if let color = colors.first(where: { $0.point == grabber.node.point }) {
                    grabber.updateLocation(color.location, meshSize: CGSize(width: width, height: height), size: CGSize(width: bounds.width, height: bounds.height))
                }
            }
        }
    }
    
    final func createGrabber(_ node: MeshNode.Color) -> GrabberView {
        let view = GrabberView(node, meshSize: CGSize(width: width, height: height), parentSize: bounds.size)
        view.translatesAutoresizingMaskIntoConstraints = true
        
        let pointerInteraction = UIPointerInteraction(delegate: self)
        view.addInteraction(pointerInteraction)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(updateGesture))
        panGesture.allowedScrollTypesMask = [.all]
        
        view.addGestureRecognizer(panGesture)
        
        return view
    }
    
    @objc func updateGesture(_ recognizer: UIPanGestureRecognizer) {
        guard let grabberView = grabberViews.first(where: { $0.node == (recognizer.view as? GrabberView)?.node }) else { return }
        let location = recognizer.location(in: self)
        
        print(grabberView.node)
        
//        let xLocation = location.x - (bounds.width / 2)
//        let minXLocation = max(xLocation, -bounds.width / 2)
//        let maxXLocation = min(minXLocation, bounds.width / 2)
//        grabberViews[viewIndex].center.x = maxXLocation
//
//        let yLocation = location.y - (bounds.height / 2)
//        let minYLocation = max(yLocation, -bounds.height / 2)
//        let maxYLocation = min(minYLocation, bounds.height / 2)
//        grabberViews[viewIndex].center.y = maxYLocation
        
//        UIView.animate(withDuration: 0.05, delay: 0, options: [.beginFromCurrentState, .allowUserInteraction, .curveLinear]) { [weak self] in
//            self?.layoutSubviews()
//        }
        
        let width = CGFloat(width) - 1
        let height = CGFloat(height) - 1
        
        let x = min(width, max(0, location.x / (bounds.width / width)))
        let y = height - min(height, max(0, location.y / (bounds.height / height)))
        
        if let sceneDelegate = window?.windowScene?.delegate as? SceneDelegate {
            let meshService = sceneDelegate.meshService
            
            if let index = meshService.colors.firstIndex(where: { $0.point == grabberView.node.point }) {
                meshService.colors[index].location = (Float(x), Float(y))
            }
        }
    }
    
    class GrabberView: UIView {
        var node: MeshNode.Color
        
        init(_ node: MeshNode.Color, meshSize: CGSize, parentSize: CGSize? = nil) {
            self.node = node
            super.init(frame: .init(origin: .zero, size: .init(width: 50, height: 50)))
            setup(meshSize: meshSize, parentSize: parentSize)
        }
        
        override init(frame: CGRect) {
            fatalError()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        final func setup(meshSize: CGSize, parentSize: CGSize?) {
            backgroundColor = UIColor.secondarySystemFill
            layer.cornerRadius = bounds.width / 2
            
            layer.shadowOffset = CGSize(width: 0, height: 4)
            layer.shadowRadius = 10
            layer.shadowOpacity = 0.8
            
            if let size = parentSize {
                updateLocation(node.location, meshSize: meshSize, size: size)
            }
        }
        
        final func updateLocation(_ location: (x: Float, y: Float), meshSize: CGSize, size: CGSize) {
            let point = CGPoint(x: (size.width / (meshSize.width - 1)) * CGFloat(location.x),
                                y: size.height - ((size.height / (meshSize.height - 1)) * CGFloat(location.y)))
            
            UIView.animate(withDuration: 0.05, delay: 0, options: [.beginFromCurrentState, .allowUserInteraction, .curveLinear]) { [weak self] in
                self?.center = point
            }
        }
    }
}

extension GrabbersView: UIPointerInteractionDelegate {
#if !targetEnvironment(macCatalyst)
    func pointerInteraction(_ interaction: UIPointerInteraction, styleFor region: UIPointerRegion) -> UIPointerStyle? {
        return .hidden()
    }
#endif
}
