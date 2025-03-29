//
//  iCapApp.swift
//  iCap
//
//  Created by 李旭 on 2024/1/26.
//

import AppKit
import AVFoundation
import Cocoa
import Combine
import KeyboardShortcuts
import ScreenCaptureKit
import SwiftUI
import UserNotifications

@main
struct iCapApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate: AppDelegate

    @AppStorage("showMenuBarExtra") private var showMenuBarExtra = true

    @StateObject private var appState = AppState.share

    @Environment(\.dismissWindow) private var dismissWindow
    @Environment(\.openWindow) private var openWindow

    private var cancellables = Set<AnyCancellable>()

    @AppLog(category: "iCapApp")
    private var logger

    var body: some Scene {
        WindowGroup(AppWinsInfo.main.desc, id: AppWinsInfo.main.id) {
            // 设置主窗口大小和属性
            ContentView()
                .environmentObject(appState)
                .onReceive(appState.$isShow) { isShow in
//                  在这里处理isShow状态变化
                    logger.info("isShow状态变化: \(isShow)")
                    if isShow {
                        // 显示窗口
                        openWindow(id: AppWinsInfo.overlayer.id)
                    } else {
                        dismissWindow(id: AppWinsInfo.overlayer.id)
                    }
                }
        }
        .windowResizability(.contentSize)
        .defaultSize(CGSize(width: 800, height: 600))
        .windowResizability(.contentSize)
        .handlesExternalEvents(matching: Set(arrayLiteral: "main"))

        WindowGroup(AppWinsInfo.overlayer.desc, id: AppWinsInfo.overlayer.id) {
            OverlayerView()
                .environmentObject(appState)
                .onAppear {
                    // 查找 title 为 Overlayer 的窗口
                    if let window = NSApplication.shared.windows.first(where: { $0.title == AppWinsInfo.overlayer.desc }) {
                        // 获取屏幕的尺寸，并设置为窗口大小
                        if let screen = NSScreen.main {
                            window.setFrame(screen.frame, display: true)
                        }
                        window.level = .screenSaver
                    }
                }
        }
        .windowStyle(.plain)
        .commands {
            CommandMenu("操作") {
                Button("取消") {
                    // 这里关闭该窗口
                    dismissWindow(id: "overlayer")
                    appState.isShow = false
                }
                .keyboardShortcut(.escape, modifiers: [.command]) // 绑定 ESC 键
            }
        }

        MenuBarExtra(
            "App Menu Bar Extra", image: "menubar",
            isInserted: $showMenuBarExtra)
        {
            StatusMenu().environmentObject(appState)
        }.menuBarExtraStyle(.menu)
    }
}

@MainActor
class AppDelegate: NSObject, NSApplicationDelegate, SCStreamDelegate, SCStreamOutput {
    @AppLog(category: "AppDelegate")
    private var logger

    var eventMonitor: Any?
    var filter: SCContentFilter?
    var appState: AppState = .share
    // private var cancellables = Set<AnyCancellable>()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let shortcut = KeyboardShortcuts.Shortcut(KeyboardShortcuts.Key.x, modifiers: [NSEvent.ModifierFlags.command, NSEvent.ModifierFlags.shift])
        KeyboardShortcuts.setShortcut(shortcut, for: .startScreenShot)

        KeyboardShortcuts.onKeyUp(for: .startScreenShot) { [self] in
            self.takeScreenShot()
        }
        
        requestScreenRecordingPermission()
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false
    }

    func applicationWillTerminate(_ notification: Notification) {
        logger.info("applicationWillTerminate")
    }

    func requestScreenRecordingPermission() {}

    @MainActor
    func takeScreenShot() {
        logger.info("takeScreenShot")
        Task {
            if (try? await SCContext.getScreenImage()) != nil {
                logger.info("getScreenImage success")
                appState.setIsShow(true)
            }
        }
    }
}
