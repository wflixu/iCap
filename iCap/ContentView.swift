//
//  ContentView.swift
//  iCap
//
//  Created by 李旭 on 2024/1/26.
//

import AppKit
import CoreImage
import ScreenCaptureKit
import SwiftData
import SwiftUI
import SwiftUIX
import AVFoundation

struct ContentView: View {
    @State private var isEditing: Bool = false
    @State var searchText: String = ""
    @State private var isAppLaunchedByHotkey = false
    @State private var isCapturingSelection = false
    @State private var selectionRect: NSRect?
    @State private var  capimg: NSImage?

    var cgimage: NSImage?
    
    var body: some View {
        VStack {
            Button(action: {
                takeScreenshot(of: nil)
            }) {
                Text("捕获整个屏幕")
            }

            Button(action: {
                isCapturingSelection = true
            }) {
                Text("捕获选定区域")
            }

//            if isCapturingSelection {
//                CrosshairView(selectionRect: $selectionRect)
//            }
        }
        VStack {
            if capimg != nil {
                Image(nsImage: capimg!)
            }
        }
        Text("test")
        HStack {
//            MyContextMenuView(title: $searchText)
            Text("test")

            SettingsLink(label: {
                /*@START_MENU_TOKEN@*/Text("Settings")/*@END_MENU_TOKEN@*/
            })
            Button("shotcut") {
                print("clock")
            }.keyboardShortcut("X", modifiers: [.command, .shift])

        }.onAppear {
            print("contentview appear")
        }
        .onDisappear {}
    }

    func takeScreenshot(of rect: NSRect?) {
        Task {
            let availableContent = try? await SCShareableContent.current

            guard let availableContent = availableContent,
                  let display = availableContent.displays.first
            else {
                print("not display")
                return ;
            }

            let myContentFilter = SCContentFilter(display: display,
                                                  excludingApplications: [], exceptingWindows: [])
            let myConfiguration = SCStreamConfiguration()
            if let res = try? await SCScreenshotManager.captureImage(contentFilter: myContentFilter, configuration: myConfiguration) {
                
                self.capimg = NSImage(cgImage: res, size: CGSize(width: 600, height: 400))
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
