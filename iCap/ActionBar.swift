//
//  AreaSelector.swift
//  iCap
//
//  Created by 李旭 on 2024/4/27.
//

import AppKit
import Foundation
import SwiftUI

struct ActionBar: View {
    @State private var selectPath = false
    @AppStorage("imageFormat") private var imageFormat: ImageFormat = .png
    @AppStorage("imageSavePath") private var imageSavePath: String = "/Users/"
    
    var body: some View {
        ZStack (alignment: Alignment(horizontal: .leading, vertical: .top)) {
            HStack(alignment: .center) {
                    Spacer()
                    Button("Save", systemImage: "square.and.arrow.down", action: onSaveFile)
                    Button("Save", systemImage: "clipboard", action: onSave)
                    Button("添加性质", systemImage: "clipboard", action: onSave)

            }
            .frame(height: 36)
            .background(.red)
        }
        .frame(width: 510, height:36)
    }

    func onSave() {
        SCContext.saveImage()
        SCContext.closeWindows()
    }
    func onSaveFile() {
        SCContext.saveImage(.file)
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
