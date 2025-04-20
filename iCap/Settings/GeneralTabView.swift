//
//  GeneralTabView.swift
//  iCap
//
//  Created by 李旭 on 2025/3/29.
//

import SwiftUI

import AppKit
import AVFoundation
import CoreImage
import Foundation
import KeyboardShortcuts
import ScreenCaptureKit
import SwiftData

struct GeneralTabView: View {
    @AppLog(category: "iCapApp")
    private var logger

    @AppStorage("imageFormat") private var imageFormat: ImageFormat = .png
    @AppStorage("imageSavePath") private var imageSavePath: String = Util.getDesktopPath()
    @State var showPathPicker: Bool = false

    @EnvironmentObject var appState: AppState

    @Environment(\.openWindow) private var openWindow

    var body: some View {
        VStack {
            Section {
                Form {
                    KeyboardShortcuts.Recorder("截屏快捷键:", name: .startScreenShot)
                    // KeyboardShortcuts.Recorder("立即截屏:", name: .takeScreenshot)
                    Picker("保存图片格式", selection: $imageFormat) {
                        Text("png").tag(ImageFormat.png)
                        Text("jpeg").tag(ImageFormat.jpeg)
                    }.padding([.leading, .trailing, .bottom], 10)
                    HStack {
                        Button("图片保存路径") {
                            showPathPicker = true
                        }.fileImporter(isPresented: $showPathPicker, allowedContentTypes: [.directory], allowsMultipleSelection: false) { result in

                            switch result {
                                case .success(let dirs):

                                    for dir in dirs {
                                        // 进入安全范围
                                        let success = dir.startAccessingSecurityScopedResource()
                                        if success {
                                            // 完成后释放资源
                                            logger.info("startAccessingSecurityScopedResource success")
                                            Util.saveBookmark(for: dir, key: Keys.savePathBookmarkStorage)
                                            //                            folderURL.stopAccessingSecurityScopedResource()
                                        } else {
                                            logger.warning("fail access scope \(dir.path)")
                                        }
                                        print(dir.path)
                                        // 获取bookmark 权限
                                        imageSavePath = dir.path
                                    }

                                case .failure(let error):
                                    // handle error
                                    print(error)
                            }
                        }
                        Spacer()

                        Text(imageSavePath)
                    }
                }
            }
            .padding([.top], 40)

            Spacer()

            HStack {
                Spacer()
                Button("保存", systemImage: "square.and.arrow.down", action: takeScreenShot)
                Button("设置", action: {
                    openWindow(id: AppWinsInfo.editor.id)
                })
                Spacer()
            }
        }
    }

    @MainActor
    func takeScreenShot() {
        logger.info("Start taking screenshot")
        Task {
            if await appState.getScreenImage() {
                logger.info("Screenshot captured successfully")
                appState.setIsShow(true)
            } else {
                logger.error("Failed to capture screenshot: No image returned")
            }
        }
    }
}

#Preview {
    GeneralTabView()
}
