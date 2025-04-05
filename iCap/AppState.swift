//
//  AppState.swift
//  iCap
//
//  Created by 李旭 on 2025/1/17.
//

import AppKit
import Combine
import KeyboardShortcuts

@MainActor
class AppState: ObservableObject {
    @AppLog(category: "AppState")
    private var logger
    
    @Published
    var isUnicornMode: Bool = false
    // overlayer is show
    @Published
    var isShow: Bool = false
    
    init() {
//        KeyboardShortcuts.onKeyUp(for: .startScreenShot) { [self] in
//            print("------\(self.self)")
//            self.takeScreenShot()
//        }
    }
    
    static var share = AppState()
    
    @MainActor
    func takeScreenShot() {
        print("takeScreenShot")
        Task {
            if (try? await SCContext.getScreenImage()) != nil {
                self.logger.info("takeScreenShot success")
            }
        }
    }

    func setIsShow(_ isShow: Bool) {
        self.logger.info("start show overlayer")
        self.isShow = isShow
    }
    
    func hideOverlayerWin() {
        print("start hide overlayer")
        self.isShow = false
        if let window = NSApplication.shared.windows.first(where: { $0.title == "Item-0" }) {
            window.close()
        } else {
            print("hide overlayer failed - window not found")
        }
    }
}
