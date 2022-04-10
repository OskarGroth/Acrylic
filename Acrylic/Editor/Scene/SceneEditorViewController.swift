//
//  SceneEditorViewController.swift
//  Acrylic
//
//  Created by Ethan Lipnik on 3/29/22.
//

import UIKit
import SwiftUI

class SceneEditorViewController: EditorViewController<SceneDocument> {
    
    var sceneService: SceneService
    
    init(_ document: SceneDocument) {
        self.sceneService = .init(document)
        super.init(document, viewControllers: [:])
        
        let primaryViewController = UINavigationController(rootViewController: UIHostingController(rootView: SceneOptionsView { [weak self] in
            self?.dismiss(animated: true)
        }.environmentObject(sceneService)))
        
        let secondaryViewController = SceneViewController(sceneService)
        
        editorViewControllers = [
            .primary: primaryViewController,
            .secondary: secondaryViewController,
            .compact: UIViewController()
        ]
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
