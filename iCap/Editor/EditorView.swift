//
//  EditorView.swift
//  iCap
//
//  Created by 李旭 on 2025/12/20.
//

import SwiftUI

struct EditorView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var annotationManager: AnnotationManager

    var body: some View {
        NavigationSplitView {
            // Annotation panel on the left
            AnnotationPanel()
        } detail: {
            // Main canvas area in the center
            ZStack {
                // Background
                Color(.sRGB, red: 0.8, green: 0.8, blue: 0.8, opacity: 0.5)
                    .ignoresSafeArea()
                
                // Canvas view
                CanvasView(frame: CGRect.zero)
                    .padding()
            }
            .safeAreaInset(edge: .bottom) {
                // Action bar at the bottom
                ActionBarView()
                    .padding()
                    .background(.ultraThickMaterial)
            }
        }
        .safeAreaInset(edge: .trailing) {
            // Properties panel on the right
            PropertiesPanel()
                .background(.ultraThickMaterial)
        }
        .navigationTitle("Annotation Editor")
    }
}

#Preview {
    EditorView()
        .environmentObject(AppState.share)
        .environmentObject(AnnotationManager())
}