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
import CoreGraphics
import KeyboardShortcuts
import OSLog
import ScreenCaptureKit
import SwiftUI
import UserNotifications

let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "iCapApp")

@main
struct iCapApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate: AppDelegate

    @AppStorage("showMenuBarExtra") private var showMenuBarExtra = true

    @StateObject private var appState = AppState.share

    @Environment(\.dismissWindow) private var dismissWindow
    @Environment(\.openWindow) private var openWindow

    private var cancellables = Set<AnyCancellable>()

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
                .onReceive(appState.$showPin) { showPin in
//                  在这里处理isShow状态变化
                    logger.info("showPin状态变化: \(showPin)")
                    if showPin {
                        logger.info("open wind \(AppWinsInfo.pinboard.desc)")
                        // 显示窗口
                        openWindow(id: AppWinsInfo.pinboard.id)
                    } else {
                        dismissWindow(id: AppWinsInfo.pinboard.id)
                    }
                }
        }
        .windowResizability(.contentSize)
        .defaultSize(CGSize(width: 800, height: 600))
        .windowResizability(.contentSize)
        .handlesExternalEvents(matching: Set(arrayLiteral: "main"))
        .defaultAppStorage(UserDefaults.group)

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
        .windowLevel(.floating)
        .commands {
            CommandMenu("操作") {
                Button("取消") {
                    // 这里关闭该窗口
                    dismissWindow(id: "overlayer")

                    appState.resetState()
                }
                .keyboardShortcut(.escape, modifiers: [.command]) // 绑定 ESC 键
            }
        }
        .defaultAppStorage(UserDefaults.group)

        // 固定图片
        WindowGroup(AppWinsInfo.pinboard.desc, id: AppWinsInfo.pinboard.id) {
            PinImageView()
                .environmentObject(appState)
                .onAppear {
                    if let window = NSApplication.shared.windows.first(where: { $0.title == AppWinsInfo.pinboard.desc }) {
                        // 设置视图显示在所有桌面空间
                        window.collectionBehavior = [.canJoinAllSpaces]
                    } else {
                        logger.warning("not window find by title\(AppWinsInfo.pinboard.desc)")
                    }
                }
        }
        .windowStyle(.plain)
        .windowLevel(.floating)
        
        .commands {
//            CommandMenu("操作") {
//                Button("取消") {
//                    // 这里关闭该窗口
//                    dismissWindow(id: "overlayer")
//
//                    appState.resetState();
//                }
//                .keyboardShortcut(.escape, modifiers: [.command]) // 绑定 ESC 键
//            }
        }
        .defaultAppStorage(UserDefaults.group)

        MenuBarExtra(
            "App Menu Bar Extra", image: "menubar",
            isInserted: $showMenuBarExtra)
        {
            StatusMenu().environmentObject(appState)
        }.menuBarExtraStyle(.menu)
            .defaultAppStorage(UserDefaults.group)
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
        if let shortcut = KeyboardShortcuts.getShortcut(for: .startScreenShot) {
            logger.info("当前设置快捷键是：\(shortcut.description)")
        } else {
            logger.warning("没有设置快捷键，使用默认值")
            let shortcut = KeyboardShortcuts.Shortcut(KeyboardShortcuts.Key.x, modifiers: [NSEvent.ModifierFlags.command, NSEvent.ModifierFlags.shift])
            KeyboardShortcuts.setShortcut(shortcut, for: .startScreenShot)
        }

        KeyboardShortcuts.onKeyUp(for: .startScreenShot) { [self] in
            self.takeScreenShot()
        }
        initAppConfig()
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false
    }

    func applicationWillTerminate(_ notification: Notification) {
        logger.info("applicationWillTerminate")
    }

    func initAppConfig() {
        logger.info("initAppConfig")
        let _ = Util.restoreFolderAccess(key: Keys.savePathBookmarkStorage)
//        checkScreenRecordingPermission()
    }

    @MainActor
    func checkScreenRecordingPermission() {
        // 检查权限
        let hasPermission = CGPreflightScreenCaptureAccess()
        if !hasPermission {
            // 请求权限（实际会跳转系统设置）
            let requestResult = CGRequestScreenCaptureAccess()
            if !requestResult {
                logger.warning("用户未授权或权限获取失败")
            }
        }
    }

    @MainActor
    func takeScreenShot() {
        logger.info("takeScreenShot")
        Task {
            if await appState.getScreenImage() {
                logger.info("getScreenImage success")
                appState.setIsShow(true)
            }
        }
    }
}
