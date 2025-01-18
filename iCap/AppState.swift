//
//  AppState.swift
//  iCap
//
//  Created by 李旭 on 2025/1/17.
//

import Combine
import KeyboardShortcuts
import AppKit

@MainActor
class AppState: ObservableObject {
    @Published
    var isUnicornMode: Bool = false
    // overlayer is show
    @Published
    var isShow: Bool = false
    
    init() {
        KeyboardShortcuts.onKeyUp(for: .startScreenShot) { [self] in
            print("------\(self.self)")
        }
    }
    
    static var share  = AppState()
    
    func showOverlayer() {
        print("start show overlayer")
        self.isShow = true
        // 打开 id 为 overlayer 的窗口
        NSApplication.shared.windows.forEach { nsw in
            print("the window: \(nsw.title)")
        }
        if let window = NSApplication.shared.windows.first(where: { $0.title == "Item-0" }) {
            window.level = .screenSaver
            window.makeKeyAndOrderFront(nil)
        }else {
            print("start show overlayer failed")
        }
    }
}
