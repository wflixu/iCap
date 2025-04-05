//
//  ImageDrawView.swift
//  iCap
//
//  Created by 李旭 on 2024/4/28.
//

import AppKit
import Foundation
import SwiftUI
import Observation

// 定义共享数据类，符合 Observable 协议
@Observable
class SharedData {
    var message: String = "Hello, World!"
}

struct ParentView: View {
    @State private var sharedData = SharedData() // 使用 @State 来管理共享数据对象

    var body: some View {
        VStack {
            Text("Parent View: \(sharedData.message)")
            ChildView(sharedData: sharedData) // 将共享数据对象传递给子视图
            
            Button("start message") {
                sharedData.message = "message from parent"
            }
        }
        .padding()
        .border(Color.red, width: 2)
    }
}

struct ChildView: View {
    var sharedData: SharedData // 引用传递的共享数据对象

    var body: some View {
        VStack {
            Text("Child View: \(sharedData.message)")
            Button(action: {
                sharedData.message = "Message Changed from Child!" // 修改共享数据对象的属性
            }) {
                Text("Change Message")
            }
        }
        .border(Color.blue, width: 2)
    }
}


struct ImageDrawView: View {
    @State private var showImport: Bool = false
    
    @State private var image: NSImage?
    
    var body: some View {
        VStack {
            HStack {
                Canvas { context, size in
                    context.stroke(
                        Path(ellipseIn: CGRect(origin: .zero, size: size)),
                        with: .color(.green),
                        lineWidth: 4)
                }
                .frame(width: 300, height: 200)
                .border(Color.blue)
            }
            HStack {
                ParentView()
            }
            HStack {
                Button("load image") {
                    showImport = true
                }
                .fileImporter(isPresented: $showImport, allowedContentTypes: [.png, .jpeg], allowsMultipleSelection: false) { result in
                    switch result {
                        case .success(let files):
                            for file in files {
                                if let originalImage = NSImage(byReferencingFile: file.path) {
                                    image = originalImage
                                }
                                print(file.path)
                            }
                            
                        case .failure(let error):
                            // handle error
                            print(error)
                    }
                }
                Button(action: {
                    startDraw()
                }, label: {
                    Text("Start")
                })
            }
            VStack {
                if let image = image {
                    Image(nsImage: image)
                }
            }.frame(width: 600, height: 400)
                .background(.blue)
            
        }.frame(width: 600, height: 440)
    }

    func startDraw() {
        guard let image else {
            return
        }
        let newImage = NSImage(size: image.size)
        newImage.lockFocus()
                  
        // 将原始图片绘制到新图片上
        image.draw(in: NSMakeRect(0, 0, image.size.width, image.size.height))
                  
        // 开始绘制形状
        let bezierPath = NSBezierPath()
                  
        // 添加一个圆环
        bezierPath.lineWidth = 20.0 // 圆环的宽度
        let ringRect = NSRect(x: 50.0, y: 50.0, width: 200.0, height: 200.0) // 圆环的位置和大小
        bezierPath.appendRect(ringRect)
        NSColor.blue.setFill()
        bezierPath.fill()
        NSColor.black.setStroke()
        bezierPath.stroke()
                  
        // 添加一个箭头（这里以简单的三角形为例）
        bezierPath.lineWidth = 5.0
        bezierPath.move(to: NSPoint(x: 300.0, y: 150.0)) // 箭头的起点
        bezierPath.line(to: NSPoint(x: 350.0, y: 100.0)) // 箭头的一个顶点
        bezierPath.line(to: NSPoint(x: 350.0, y: 200.0)) // 箭头的另一个顶点
        bezierPath.close()
        NSColor.red.setFill()
        bezierPath.fill()
                  
        // 结束绘制
        newImage.unlockFocus()
        
        self.image = newImage
    }
}

#Preview {
    ImageDrawView()
}
