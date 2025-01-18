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

struct ContentView: View {
    @AppStorage("imageFormat") private var imageFormat: ImageFormat = .png
    @AppStorage("imageSavePath") private var imageSavePath: String = "/Users/"

    @State var showPathPicker: Bool = false
    var body: some View {
        VStack {
            Form {
                Section(header: Text("iCap 设置")) {
                    KeyboardShortcuts.Recorder("截屏快捷键:", name: .startScreenShot)
                    Picker("保存图片格式", selection: $imageFormat) {
                        Text("png").tag(ImageFormat.png)
                        Text("jpeg").tag(ImageFormat.jpeg)
                    }.padding([.leading, .trailing, .bottom], 10)
                    HStack {
                        Button("图片保存路径") {
                            showPathPicker = true
                        }.fileImporter(isPresented: $showPathPicker, allowedContentTypes: [.directory], allowsMultipleSelection: false) { result in

                            switch result {
                                case .success(let dirs):

                                    for dir in dirs {
                                        print(dir.path)
                                        imageSavePath = dir.path
                                    }

                                case .failure(let error):
                                    // handle error
                                    print(error)
                            }
                        }
                        Spacer()

                        Text(imageSavePath)
                    }
                }
            }
            Spacer()
        }.frame(width: 800, height: 800)
            .onAppear {
                initSavePath()
            }
    }

    func initSavePath() {
        let home = URL.homeDirectory
        imageSavePath = home.path + "/Desktop"
    }
}

#Preview {
    ContentView()
       
}
