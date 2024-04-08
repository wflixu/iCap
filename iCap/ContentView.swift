//
//  ContentView.swift
//  iCap
//
//  Created by 李旭 on 2024/1/26.
//

import SwiftData
import SwiftUI
import SwiftUIX
import AppKit


struct ContentView: View {
    @State private var isEditing: Bool = false
    @State var searchText: String = ""

    var body: some View {
        Text("test")
        HStack {
//            MyContextMenuView(title: $searchText)
            Text("test")
            
            SettingsLink(label: {
                /*@START_MENU_TOKEN@*/Text("Settings")/*@END_MENU_TOKEN@*/
            })
        }
        
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
