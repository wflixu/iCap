//
//  ContentView.swift
//  iCap
//
//  Created by 李旭 on 2024/1/26.
//

import AppKit
import AVFoundation
import CoreImage
import Foundation
import KeyboardShortcuts
import ScreenCaptureKit
import SwiftData
import SwiftUI

enum Tabs: String, CaseIterable, Identifiable {
    case general = "General"
    case about = "About"

    var id: String { self.rawValue }

    var icon: String {
        switch self {
        case .general: "slider.horizontal.2.square"
        case .about: "exclamationmark.circle"
        }
    }

    var title: String {
        switch self {
        case .general: "General Settings"
        case .about: "About"
        }
    }
}

struct ContentView: View {
    @Environment(\.openWindow) private var openWindow

    @State private var selectedTab: Tabs = .general
    @EnvironmentObject var appState: AppState

    var body: some View {
        NavigationSplitView {
            self.sidebar.onAppear {
                print("Sidebar appeared!") // 检查控制台输出
            }
        } detail: {
            self.detailView
        }
        .navigationTitle(LocalizedStringKey(self.selectedTab.title))
        .navigationSplitViewStyle(.balanced)
    }

    @ViewBuilder
    private var sidebar: some View {
        Section {
            HStack {
                Text("test")
            }
            Divider()
            
            List(selection: self.$selectedTab) {
                ForEach(Tabs.allCases, id: \.self) { tab in
                    HStack {
                        // 使用固定大小的frame来确保图标大小一致
                        Label {
                            Text(LocalizedStringKey(tab.rawValue))
                                .font(.title2)
                        } icon: {
                            Image(systemName: tab.icon)
                                .font(.title2)
                                .frame(width: 24, height: 24)
                        }
                        .padding(.all, 8)
                        .labelStyle(.titleAndIcon)
                        Spacer(minLength: 0)
                    }
                    .onTapGesture {
                        self.selectedTab = tab
                    }
                }
            }
            .listStyle(SidebarListStyle())
            .scrollDisabled(true)
            .navigationSplitViewColumnWidth(210)
        } header: {
            //  App Icon 部分
            VStack {
                HStack {
                    Spacer()
                    Image("Logo")
                        .resizable()
                        .frame(width: 64, height: 64)
                    Spacer()
                }
                HStack(alignment: .bottom) {
                    Spacer()
                    Text("iCap").font(.title)
                    Text("\(self.getAppVersion())")
                    Spacer()
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 24)
        }
        .removeSidebarToggle()
    }

    @ViewBuilder var detailView: some View {
        // 右侧内容
        Group {
            switch self.selectedTab {
            case .general:
                GeneralTabView()
            case .about:
                AboutTabView()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }

    func getAppVersion() -> String {
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            return version
        }
        return "Unknown"
    }
}

extension View {
    /// Removes the sidebar toggle button from the toolbar.
    func removeSidebarToggle() -> some View {
        toolbar(removing: .sidebarToggle)
            .toolbar {
                Color.clear
            }
    }
}

#Preview {
    ContentView()
}
