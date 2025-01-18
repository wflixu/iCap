//
//  AreaSelector.swift
//  iCap
//
//  Created by 李旭 on 2024/4/27.
//

import AppKit
import Foundation
import SwiftUI
import UniformTypeIdentifiers

struct ActionBar: View {
    @State private var showSelectPath = false

    @State private var isShowingFileExporter = false

    @AppStorage("imageFormat") private var imageFormat: ImageFormat = .png
    @AppStorage("imageSavePath") private var imageSavePath: String = "/Users/"

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
        let _data = SCContext.saveImage()
        SCContext.closeWindows()
    }

    func onSaveFile() {
        if let imageData = SCContext.saveImage(.file) {
            let savePanel = NSSavePanel()
            savePanel.allowedContentTypes = [.png]
            savePanel.nameFieldStringValue = Util.getDatetimeFileName()

            savePanel.begin { result in
                if result == .OK, let url = savePanel.url {
                    do {
                        try imageData.write(to: url)
                        print("Image saved successfully at: \(url.path)")
                    } catch {
                        print("Error saving image: \(error.localizedDescription)")
                    }
                } else {
                    print("Save operation canceled by the user.")
                }
            }
        }
        SCContext.closeWindows()
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
    ActionBar()
}
