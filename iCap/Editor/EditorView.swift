//
//  ImageDrawView.swift
//  iCap
//
//  Created by 李旭 on 2024/4/28.
//

import CoreGraphics
import SwiftUI

// 标注视图实现
struct AnnotationView: View {
//    let cgImage: CGImage
    var annotations: [Annotation] = []
    
    var body: some View {
        ZStack {
            Canvas { context, size in
                // 绘制原始图片
//                let imageRect = CGRect(origin: .zero, size: size)
//                context.draw(Image(decorative: cgImage, scale: 1.0), in: imageRect)
                
                // 绘制所有标注
                for annotation in annotations {
                    switch annotation.type {
                    case .rect:
                        drawRect(context: context, annotation: annotation, size: size)
                    case .text:
                        drawText(context: context, annotation: annotation, size: size)
                    case .arrow:
                        drawArrow(context: context, annotation: annotation, size: size)
                    }
                }
            }
        }.frame(width: 600, height: 400)
            .background(Color.green)
    }
    
    // 绘制矩形
    private func drawRect(context: GraphicsContext, annotation: Annotation, size: CGSize) {
        let path = Path(roundedRect: annotation.frame, cornerRadius: 0)
        context.stroke(path, with: .color(annotation.color), lineWidth: annotation.lineWidth)
    }
    
    // 绘制文字
    private func drawText(context: GraphicsContext, annotation: Annotation, size: CGSize) {
        let text = Text(annotation.text)
            .font(.system(size: 16))
            .foregroundColor(annotation.color)
        
        context.draw(text, at: CGPoint(
            x: annotation.frame.midX,
            y: annotation.frame.midY
        ), anchor: .center)
    }
    
    // 绘制箭头
    private func drawArrow(context: GraphicsContext, annotation: Annotation, size: CGSize) {
        let start = CGPoint(x: annotation.frame.minX, y: annotation.frame.minY)
        let end = CGPoint(x: annotation.frame.maxX, y: annotation.frame.maxY)
        
        // 绘制主线
        var path = Path()
        path.move(to: start)
        path.addLine(to: end)
        context.stroke(path, with: .color(annotation.color), lineWidth: annotation.lineWidth)
        
        // 绘制箭头头部
        let angle = atan2(end.y - start.y, end.x - start.x)
        let arrowLength: CGFloat = 10
        
        let arrowPath = Path { path in
            path.move(to: end)
            path.addLine(to: CGPoint(
                x: end.x - arrowLength * cos(angle - .pi/6),
                y: end.y - arrowLength * sin(angle - .pi/6)
            ))
            path.addLine(to: CGPoint(
                x: end.x - arrowLength * cos(angle + .pi/6),
                y: end.y - arrowLength * sin(angle + .pi/6)
            ))
                         
            path.closeSubpath()
        }
        
        context.fill(arrowPath, with: .color(annotation.color))
    }
}

// 标注控制器
class AnnotationController: ObservableObject {
    @Published var annotations: [Annotation] = []
    var currentAnnotationType: AnnotationType = .rect
    
    // 添加新标注
    func addAnnotation(type: AnnotationType, frame: CGRect, text: String = "") {
        let annotation = Annotation(
            type: type,
            frame: frame,
            text: text
        )
        annotations.append(annotation)
    }
    
    // 将标注后的视图转换为CGImage
    
    @MainActor
    func renderAnnotationView(size: CGSize) -> CGImage? {
        let renderer = ImageRenderer(
            content: AnnotationView(annotations: annotations)
                .frame(width: size.width, height: size.height)
        )
         
        return renderer.cgImage
    }
}

// 使用示例
struct EditorView: View {
    @StateObject private var controller = AnnotationController()
    @State var originalImage: CGImage? // 你的原始CGImage
    
    var body: some View {
        VStack {
            ZStack {
                AnnotationView(annotations: controller.annotations)
                    .frame(width: 600, height: 400)
                    .gesture(DragGesture().onEnded { value in
                        let frame = CGRect(
                            origin: value.startLocation,
                            size: CGSize(
                                width: value.translation.width,
                                height: value.translation.height
                            )
                        )
                        controller.addAnnotation(
                            type: controller.currentAnnotationType,
                            frame: frame
                        )
                    })
                
            }.frame(width: 600, height: 400)
                .background(Color.white)
           
            // 工具选择
            HStack {
                Button("矩形") { controller.currentAnnotationType = .rect }
                Button("箭头") { controller.currentAnnotationType = .arrow }
                Button("文字") { controller.currentAnnotationType = .text }
                Button("保存") {
                    if let renderedImage = controller.renderAnnotationView(
                        size: CGSize(width: 600, height: 400)
                    ) {
                        saveImage(renderedImage)
                    }
                }
            }.frame(width: 300, height: 40)
        }
    }
    
    private func saveImage(_ cgImage: CGImage) {
        // 实现你的保存逻辑
    }
}
