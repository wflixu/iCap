//
//  iCapApp.swift
//  iCap
//
//  Created by 李旭 on 2024/1/26.
//

import AppKit
import AVFoundation
import Cocoa
import KeyboardShortcuts
import ScreenCaptureKit
import SwiftUI
import UserNotifications

@main
struct iCapApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate: AppDelegate

    @AppStorage("showMenuBarExtra") private var showMenuBarExtra = true

    @StateObject private var appState = AppState.share

    var body: some Scene {
        WindowGroup("iCap", id: "main") {
            ContentView()
                .navigationTitle("iCap")
                .onAppear {}
        }
        .handlesExternalEvents(matching: Set(arrayLiteral: "main"))

        WindowGroup("Overlayer", id: "overlayer") {
            OverlayerView()
                .onAppear {
                    // 查找 title 为 Overlayer 的窗口
                    if let window = NSApplication.shared.windows.first(where: { $0.title == "Overlayer" }) {
                        // 获取屏幕的尺寸，并设置为窗口大小
                        if let screen = NSScreen.main {
                            window.setFrame(screen.frame, display: true)
                        }
                        window.level = .screenSaver
                    }
                }
        }
        .windowStyle(.plain)


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
    var eventMonitor: Any?
    var filter: SCContentFilter?
    var appState: AppState = .share

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let shortcut = KeyboardShortcuts.Shortcut(KeyboardShortcuts.Key.x, modifiers: [NSEvent.ModifierFlags.command, NSEvent.ModifierFlags.shift])
        KeyboardShortcuts.setShortcut(shortcut, for: .startScreenShot)

        // KeyboardShortcuts.onKeyUp(for: .startScreenShot) { [self] in
        //     takeScreenShot()
        // }

        requestScreenRecordingPermission()
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }

    func requestScreenRecordingPermission() {}

    @MainActor
    func takeScreenShot() {
        print("takeScreenShot")
        Task {
            if let _res = try? await SCContext.getScreenImage() {
                appState.showOverlayer()
            }
        }
    }
}
