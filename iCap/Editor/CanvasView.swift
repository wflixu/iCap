//
//  CanvasView.swift
//  iCap
//
//  Created by 李旭 on 2025/4/26.
//

import SwiftUI

struct CanvasView: View {
    @EnvironmentObject var appState: AppState
    // 用于存储所有可拖动形状的数据
    @State private var annotations: [Annotation] = []

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
            ForEach(annotations) { annotation in
                AnnotationView(annotation: annotation)
                    .position(x: annotation.frame.midX - frame.minX, y: annotation.frame.midY - frame.minY)
            }
           

            Color.clear
                .contentShape(Rectangle())
                .gesture(canvasDragGesture)

            if let ann = activeAnnotation {
                ActiveAnnotationView(annotation: ann, onUpdateFrame: { offset, size in
                    if let index = annotations.firstIndex(where: { $0.id == ann.id }) {
                        annotations[index].frame.origin.x += offset.width
                        annotations[index].frame.origin.y += offset.height
                        annotations[index].frame.size.width += size.width
                        annotations[index].frame.size.height += size.height
                    }
                    logger.info("更新标注位置: \(offset.width) - 大小: \(size.width)")
                    self.updateActiveAnnotation(offset, size)

                })
                .position(x: ann.frame.midX - frame.minX, y: ann.frame.midY - frame.minY)
            }
        }
         .onReceive(EventBus.shared.publisher(for: "saveDrawing")) { _ in
                saveCanvas()
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

                self.annotations.append(activeAnnotation!)
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

    private func saveCanvas() {
        logger.info("保存画布")
        if annotations.isEmpty {
            logger.warning("没有标注数据")
             EventBus.shared.post(event: "savedAnno", data: "savedAnno")
            return
        }
        // ImageRenderer用于将SwiftUI视图渲染为图像
        // 需要设置具体的尺寸，否则会使用视图的理想尺寸，可能导致比例失调
        let renderer = ImageRenderer(content: self)
        // 设置明确的渲染尺寸，使用frame的大小
        renderer.proposedSize = ProposedViewSize(width: frame.width, height: frame.height)

        if let cgImage = renderer.cgImage {
            logger.info("渲染图像尺寸: 宽度 - \(cgImage.width), 高度 - \(cgImage.height)")
            appState.annotationImage = cgImage
            // 保存
            logger.info("保存图片成功")
           EventBus.shared.post(event: "savedAnno", data: "savedAnno")
        } else {
            logger.error("保存图片失败")
        }
    }
}
