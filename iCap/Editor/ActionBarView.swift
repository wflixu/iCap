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

    @EnvironmentObject var store: AppState

    var body: some View {
        ZStack(alignment: Alignment(horizontal: .leading, vertical: .top)) {
            HStack(alignment: .center) {
                Spacer()
                Button("Save", systemImage: "square.and.arrow.down", action: onSaveFile)
                Button("Save", systemImage: "clipboard", action: onSave)
                Button("添加性质", systemImage: "clipboard", action: onSave)
            }

            .frame(height: 36)
            .background(.red)
        }
    }

    func onSave() {
        _ = SCContext.saveImage()
        SCContext.closeWindows()
    }

    func onSaveFile() {
        SCContext.setOverlayWindowLevel(.normal)

        if let imageData = SCContext.saveImage(.file) {
            
            let url = URL(fileURLWithPath: imageSavePath).appendingPathComponent(Util.getDatetimeFileName()).appendingPathExtension(imageFormat.rawValue)
            logger.info("Saving image to: \(url.path)")
            do {
                try imageData.write(to: url)
                print("Image saved successfully at: \(url.path)")
            } catch {
                print("Error saving image: \(error.localizedDescription)")
            }
            store.setIsShow(false)
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
