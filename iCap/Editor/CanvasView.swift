//
//  CanvasView.swift
//  iCap
//
//  Created by 李旭 on 2025/4/26.
//

import SwiftUI

struct CanvasView: View {
    @EnvironmentObject var appState: AppState

    // 激活矩形
    @State private var isDragging = false
    @State private var dragStart = CGPoint.zero
    @State private var dragOffset = CGSize.zero
    @State private var activeAnnotation: Annotation?

    var frame: CGRect
    var annotations: [Annotation] = [];

    var annotationType: AnnotationType {
        appState.annotationType
    }

    var body: some View {
        ZStack {
           
                ForEach(annotations) { annotation in
                    AnnotationView(annotation: annotation)
                        .position(x: annotation.frame.midX - frame.minX, y: annotation.frame.midY - frame.minY)
                }
            

            Color.clear
                .contentShape(Rectangle())
                .gesture(canvasDragGesture)

            if let ann = activeAnnotation {
                ActiveAnnotationView(annotation: ann, onUpdateFrame: { offset, size in
                    if var curAnno = annotations.first(where: { $0.id == ann.id }) {
                        curAnno.frame.origin.x += offset.width
                        curAnno.frame.origin.y += offset.height
                        curAnno.frame.size.width += size.width
                        curAnno.frame.size.height += size.height
                    }
                    logger.info("更新标注位置: \(offset.width) - 大小: \(size.width)")
                    self.updateActiveAnnotation(offset, size)

                })
                .position(x: ann.frame.midX - frame.minX, y: ann.frame.midY - frame.minY)
            }
        }
       
    }

    // 更新激活标注
    func updateActiveAnnotation(_ offset: CGSize, _ size: CGSize) {
        // 更新激活标注的位置和大小
        if let oldAnnotation = activeAnnotation {
            // 根据旧标注和偏移量创建新的标注
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

    var canvasDragGesture: some Gesture {
        DragGesture(minimumDistance: 2, coordinateSpace: .named(Keys.coordinate)) // 允许零距离触发
            .onChanged { value in

                logger.debug("拖动中112122 - 坐标: (\(value.location.x), \(value.location.y))")
                // 按下时触发
                if !isDragging {
                    dragStart = value.startLocation
                    dragOffset = .zero
                    isDragging = true
                }

                // 实时更新位置
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
            .onEnded { _ in

                appState.annotations.append(activeAnnotation!)
                dragStart = .zero
                dragOffset = .zero
                isDragging = false
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
