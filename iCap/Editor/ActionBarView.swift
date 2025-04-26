//
//  ActionBarView.swift
//  iCap
//
//  Created by 李旭 on 2025/3/29.
//

import AppKit
import Foundation
import SwiftUI
import UniformTypeIdentifiers

struct ActionBarView: View {
    @AppLog(category: "ActionBarView")
    private var logger

    @State private var showSelectPath = false

    @State private var isShowingFileExporter = false

    @AppStorage("imageFormat") private var imageFormat: ImageFormat = .png
    @AppStorage("imageSavePath") private var imageSavePath: String = "/Users/"

    @EnvironmentObject var appState: AppState

    var body: some View {
        ZStack(alignment: Alignment(horizontal: .leading, vertical: .top)) {
            HStack(alignment: .center, spacing: 8) {
                Spacer()
                Button(action: {
                    self.onSaveFile()
                }) {
                    Image(systemName: "square.and.arrow.down")
                        .font(.system(size: 20, weight: .medium))
                        .frame(width: 28, height: 28)
                        .foregroundColor(.gray)
                }.buttonStyle(PlainButtonStyle())
                    .help("保存到文件")

                Button(action: {
                    self.onSave()
                }) {
                    Image(systemName: "clipboard")
                        .font(.system(size: 20, weight: .medium))
                        .frame(width: 28, height: 28)
                        .foregroundColor(.gray)
                }.buttonStyle(PlainButtonStyle())
                    .help("保存到剪贴板")

                Button(action: {
                    appState.toggleAnnotationType(.rect)
                }) {
                    Image(systemName: "rectangle")
                        .font(.system(size: 20, weight: .medium))
                        .frame(width: 28, height: 28)
                        .foregroundColor(appState.annotationType == .rect ? .accentColor : .gray)
                }.buttonStyle(PlainButtonStyle())
                    .help("矩形框")

                Button(action: {
                    appState.toggleAnnotationType(.arrow)
                }) {
                    Image(systemName: "arrow.right")
                        .font(.system(size: 20, weight: .medium))
                        .frame(width: 28, height: 28)
                        .foregroundColor(appState.annotationType == .arrow ? .accentColor : .gray)
                }.buttonStyle(PlainButtonStyle())
                    .help("箭头")

                Button(action: {
                    appState.annotationType = .text
                    appState.savingDrawing = !appState.savingDrawing
                }) {
                    Image(systemName: "character")
                        .font(.system(size: 20, weight: .medium))
                        .frame(width: 28, height: 28)
                        .foregroundColor(appState.annotationType == .text ? .accentColor : .gray)
                }.buttonStyle(PlainButtonStyle())
                    .help("文字")
            }
            .padding(.horizontal, 12)
            .frame(height: 40)
            .background(.white)
            .cornerRadius(4)
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )
            .shadow(color: .gray.opacity(0.1), radius: 2, x: 0, y: 1)
        }
    }

    func onSave() {
        EventBus.shared.post(event: "save", data: "save")
    }

    func onSaveFile() {
        Util.setOverlayWindowLevel(.normal)

        if let imageData = appState.saveImage(.file) {
            let url = URL(fileURLWithPath: imageSavePath).appendingPathComponent(Util.getDatetimeFileName()).appendingPathExtension(imageFormat.rawValue)
            logger.info("Saving image to: \(url.path)")
            do {
                try imageData.write(to: url)
                print("Image saved successfully at: \(url.path)")
            } catch {
                print("Error saving image: \(error.localizedDescription)")
            }
            appState.setIsShow(false)
        }
    }
}

enum ResizeHandle: CaseIterable {
    case none
    case topLeft, top, topRight, right, bottomRight, bottom, bottomLeft, left

    static var allCases: [ResizeHandle] {
        return [.none, .topLeft, .top, .topRight, .right, .bottomRight, .bottom, .bottomLeft, .left]
    }
}

#Preview {
    ActionBarView()
}
