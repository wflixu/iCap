//
//  iCapApp.swift
//  iCap
//
//  Created by 李旭 on 2024/1/26.
//

import SwiftData
import SwiftUI

@main
struct iCapApp: App {
    
    @NSApplicationDelegateAdaptor private var appDelegate: AppDelegate
    
    @AppStorage("showMenuBarExtra") private var showMenuBarExtra = true
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
            "App Menu Bar Extra", systemImage: "star",
            isInserted: $showMenuBarExtra)
        {
            StatusMenu()
        }.menuBarExtraStyle(.menu)
    }
}
