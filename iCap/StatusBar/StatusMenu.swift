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

    @ObservedObject private var appState = AppState.share

    
    init() {
      
    }
    
    func handleNotification(_ notification: Notification) {
        print("Receiver: Notification received!")

        // 从 userInfo 中提取数据
        openWindow(id: "overlayer")
    }
    
    var body: some View {
        VStack {
            Button("Settings", action: showSettings)
            Button("Quit", action: onQuit)
            Button("Show", action: showWins)
        }.task {
            print("statusmenu i load")
        }
    }
    
    func onQuit() {
        Task {
            try await Task.sleep(nanoseconds: UInt64(1.0 * 1e9))
            NSApplication.shared.terminate(self)
        }
    }
    
    func showSettings() {
        openWindow(id: "overlayer")
    }
    
    func showWins() {
        SCContext.showMainWindow()
    }
}

#Preview {
    StatusMenu()
}
