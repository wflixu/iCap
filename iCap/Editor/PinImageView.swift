//
//  PinImageView.swift
//  iCap
//
//  Created by 李旭 on 2025/5/5.
//

import SwiftUI

struct PinImageView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.dismissWindow) private var dismissWindow
    @GestureState private var isDraggingWindow = false
    
    var body: some View {
        ZStack {
//             显示 appState 中的 resultImage
            if let resultImage = appState.resultImage {
                Image(decorative: resultImage, scale: 1.0)
                    .resizable()
                    .scaledToFit()
                    .contextMenu {
                        Button("关闭") {
                            appState.showPin = false
                            appState.resetState()
                        }
                        Button("保存") {
                            appState.savePinImage()
                            appState.resetState()
                        }
                    }
            }
        }.frame(width: appState.cropRect.width, height: appState.cropRect.height)
            .background(Color.white ,in: RoundedRectangle(cornerRadius: 8))
            
            .gesture(WindowDragGesture())
    }
}

#Preview {
    PinImageView()
}
