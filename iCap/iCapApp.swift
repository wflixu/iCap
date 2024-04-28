//
//  iCapApp.swift
//  iCap
//
//  Created by 李旭 on 2024/1/26.
//

import SwiftData

import AppKit
import AVFAudio
import AVFoundation
import KeyboardShortcuts
import ScreenCaptureKit
import SwiftUI
import UserNotifications

@main
struct iCapApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate: AppDelegate

    @AppStorage("showMenuBarExtra") private var showMenuBarExtra = true

    @StateObject private var appState = AppState()

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup("iCap") {
            ContentView()
                .navigationTitle("iCap")
                .onAppear {}
        }.commands(content: {
            CommandMenu("my") {
                Text("my")
            }

        })
        .handlesExternalEvents(matching: Set(arrayLiteral: "main"))
        .modelContainer(sharedModelContainer)

        Settings {
            SettingsView()
        }

        MenuBarExtra(
            "App Menu Bar Extra", image: "menubar",
            isInserted: $showMenuBarExtra)
        {
            StatusMenu()
        }.menuBarExtraStyle(.menu)
    }
}

class AppDelegate: NSObject, NSApplicationDelegate, SCStreamDelegate, SCStreamOutput {
    var eventMonitor: Any?
    var filter: SCContentFilter?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let shortcut = KeyboardShortcuts.Shortcut(KeyboardShortcuts.Key.x, modifiers: [NSEvent.ModifierFlags.command, NSEvent.ModifierFlags.shift])
        KeyboardShortcuts.setShortcut(shortcut, for: .startScreenShot)

        KeyboardShortcuts.onKeyUp(for: .startScreenShot) { [self] in

            takeScreenShot()
        }
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }

    @MainActor
    func takeScreenShot() {
        print("takeScreenShot")
        Task {
            if let res = try? await SCContext.getScreenImage() {
                SCContext.showAreaSelectWindow()
            }
        }
    }
}


@MainActor
final class AppState: ObservableObject {
    var isUnicornMode: Bool = false
    init() {
        KeyboardShortcuts.onKeyUp(for: .startScreenShot) { [self] in
            print("------\(self.self)")
        }
    }
}
