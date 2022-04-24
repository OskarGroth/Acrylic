//
//  SceneOptionsView.swift
//  Acrylic
//
//  Created by Ethan Lipnik on 4/10/22.
//

import SwiftUI

struct SceneOptionsView: View {
    @EnvironmentObject var sceneService: SceneService
    @Environment(\.horizontalSizeClass) var horizontalClass
    
    var closeAction: () -> Void
    @State private var renderImage: UIImage? = nil
    
    var body: some View {
        Group {
            if UIDevice.current.userInterfaceIdiom == .pad {
                scrollView
                    .background(Color(.secondarySystemBackground).ignoresSafeArea())
                    .navigationTitle(sceneService.sceneDocument.fileURL.deletingPathExtension().lastPathComponent)
                    .toolbar {
                        ToolbarItem(placement: .navigation) {
                            Button {
                                closeAction()
                            } label: {
                                Label("Done", systemImage: "xmark.circle.fill")
                            }
                        }
                        
                        exportButton
                    }
            } else if horizontalClass == .compact && UIDevice.current.userInterfaceIdiom != .mac {
                VStack(spacing: 0) {
                    HStack {
                        Button {
                            closeAction()
                        } label: {
                            Image(systemName: "xmark")
                                .font(.title3.bold())
                        }

                        Text(sceneService.sceneDocument.fileURL.deletingPathExtension().lastPathComponent)
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .center)
                        
                        Button {
                            renderImage = sceneService.render(resolution: CGSize(width: 8000, height: 8000))
                        } label: {
                            Image(systemName: "square.and.arrow.up")
                                .font(.title3.bold())
                        }
                    }
                    .padding(.horizontal, 30)
                    .frame(height: 60)
                    Divider()
                        .opacity(0.5)
                    scrollView
                }
                .navigationBarHidden(true)
            } else {
                VStack(spacing: 0) {
                    Divider()
                        .opacity(0.5)
                    scrollView
                }
                .navigationBarHidden(true)
            }
        }
        .sheet(item: $renderImage) { renderImage in
            ExportView(renderImage: renderImage)
        }
    }
    
    var scrollView: some View {
        ScrollView {
            VStack {
                PresetView()
                CameraView()
            }.padding()
        }
    }
    
    var exportButton: some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            Button {
            } label: {
                Label("Export", systemImage: "square.and.arrow.up")
            }
        }
    }
}

struct SceneOptionsView_Previews: PreviewProvider {
    static var previews: some View {
        SceneOptionsView() {}
    }
}
