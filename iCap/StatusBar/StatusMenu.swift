//
//  StatusMenu.swift
//  iCap
//
//  Created by 李旭 on 2024/1/31.
//

import AppKit
import Combine
import SwiftUI

struct StatusMenu: View {
    
    
    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismiss) private var dismiss
    @AppStorage("imageFormat") private var imageFormat: ImageFormat = .png
    @AppStorage("imageSavePath") private var imageSavePath: String = Util.getDesktopPath()

    @ObservedObject private var appState = AppState.share


    func handleNotification(_ notification: Notification) {
        print("Receiver: Notification received!")

        // 从 userInfo 中提取数据
        openWindow(id: "overlayer")
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Group {
                Button("偏好设置") { showSettings() }

                Divider()

                Button("截图") {
                     logger.info("超简切换贴图")
                }
                    .keyboardShortcut("A", modifiers: .command)
                Button("延时全屏截图 ⌘2") {}
                Button("带亮截图 ⌘3") {}
//                Button("截图OCR ⌘4") {}
//                Button("截图翻译 ⌘5") {}
               

                Divider()
            }

            Group {
                Button("打开截图库") {
                    openSavedDirectory()
                }
                Button("打开最后保存目录") {}
                Button("隐藏基单栏") {}
                Divider()

              

                Button("退出") { onQuit() }
            }
        }
        .frame(minWidth: 200)
        .padding(.vertical, 4)
    }

    func onQuit() {
        Task {
            try await Task.sleep(nanoseconds: UInt64(1.0 * 1e9))
            NSApplication.shared.terminate(self)
        }
    }

    func showSettings() {
        Util.showOrCreateWindow(windowId: AppWinsInfo.main.id) {
            print("未找到设置窗口，创建新窗口")
            openWindow(id: AppWinsInfo.main.id)
        }
    }

    func openSavedDirectory() {
        let url = URL(fileURLWithPath: imageSavePath)
        NSWorkspace.shared.open(url)
    }
}

#Preview {
    StatusMenu()
}
