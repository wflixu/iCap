//
//  CanvasView.swift
//  iCap
//
//  Created by 李旭 on 2025/4/26.
//

import SwiftUI

struct CanvasView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var annotationManager: AnnotationManager

    // 激活矩形
    @State private var isDragging = false
    @State private var dragStart = CGPoint.zero
    @State private var dragOffset = CGSize.zero
    @State private var activeAnnotation: Annotation?

    var frame: CGRect

    var annotationType: AnnotationType {
        appState.annotationType
    }

    var body: some View {
        ZStack {
            // Render all annotations from the annotation manager
            ForEach(annotationManager.annotations) { annotation in
                AnnotationView(annotation: annotation)
                    .position(x: annotation.frame.midX - frame.minX, y: annotation.frame.midY - frame.minY)
                    .onTapGesture {
                        annotationManager.toggleSelection(annotation.id)
                    }
                    .zIndex(Double(annotation.zIndex))
            }

            Color.clear
                .contentShape(Rectangle())
                .gesture(drawGesture)

            // Show active annotation if we're currently drawing
            if let ann = activeAnnotation {
                ActiveAnnotationView(annotation: ann, onUpdateFrame: { offset, size in
                    if var curAnno = annotationManager.annotations.first(where: { $0.id == ann.id }) {
                        curAnno.frame.origin.x += offset.width
                        curAnno.frame.origin.y += offset.height
                        curAnno.frame.size.width += size.width
                        curAnno.frame.size.height += size.height
                    }
                    print("更新标注位置: \(offset.width) - 大小: \(size.width)")
                    self.updateActiveAnnotation(offset, size)
                })
                .position(x: ann.frame.midX - frame.minX, y: ann.frame.midY - frame.minY)
            }
        }
    }

    // 统一的手势处理
    private var drawGesture: some Gesture {
        DragGesture(minimumDistance: 0, coordinateSpace: .named(Keys.coordinate))
            .onChanged { value in
                // 序号标注在点击时触发，不需要拖动过程
                if annotationType == .number {
                    return
                }

                print("拖动中 - 坐标: (\(value.location.x), \(value.location.y))")
                if !isDragging {
                    dragStart = value.startLocation
                    dragOffset = .zero
                    isDragging = true
                }
                dragOffset = value.translation

                activeAnnotation = Annotation(
                    type: appState.annotationType,
                    frame: CGRect(
                        x: dragStart.x,
                        y: dragStart.y,
                        width: abs(dragOffset.width),
                        height: abs(dragOffset.height)
                    ),
                    start: dragStart,
                    offset: dragOffset
                )
            }
            .onEnded { value in
                // 序号标注：使用点击位置
                if annotationType == .number {
                    annotationManager.addNumberAnnotation(at: value.startLocation)
                    return
                }

                // 其他标注类型：添加拖拽创建的标注
                if let newAnnotation = activeAnnotation {
                    annotationManager.add(newAnnotation)
                }
                dragStart = .zero
                dragOffset = .zero
                isDragging = false
            }
    }

    // 更新激活标注
    func updateActiveAnnotation(_ offset: CGSize, _ size: CGSize) {
        if let oldAnnotation = activeAnnotation {
            let newFrame = CGRect(
                x: oldAnnotation.frame.origin.x + offset.width,
                y: oldAnnotation.frame.origin.y + offset.height,
                width: oldAnnotation.frame.width + size.width,
                height: oldAnnotation.frame.height + size.height
            )

            let newAnnotation = Annotation(
                type: oldAnnotation.type,
                frame: newFrame,
                start: oldAnnotation.start,
                offset: oldAnnotation.offset
            )

            activeAnnotation = newAnnotation
        }
    }

    private func transformCanvasCoordinate(_ rect: CGRect) -> CGRect {
        return CGRect(
            x: rect.origin.x - frame.minX,
            y: rect.origin.y - frame.minY,
            width: rect.width,
            height: rect.height
        )
    }
}
