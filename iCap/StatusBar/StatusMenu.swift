//
//  StatusMenu.swift
//  iCap
//
//  Created by 李旭 on 2024/1/31.
//

import SwiftUI
import AppKit

struct StatusMenu: View {
    var body: some View {
        VStack {
            Button("Settings", action: showSettings )
            Button("Quit", action: onQuit)
            
        }
    }
    
    func test() {}
    
    func onQuit() {
        Task {
            try await Task.sleep(nanoseconds: UInt64(1.0 * 1e9))
            await NSApplication.shared.terminate(self)
        }
    }
    func showSettings () {
        SCContext.showMainWindow()
    }
}

#Preview {
    StatusMenu()
}
