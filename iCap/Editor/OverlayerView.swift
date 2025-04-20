//
//  OverlayerView.swift
//  iCap
//
//  Created by 李旭 on 2025/1/18.
//

import AppKit
import SwiftUI

struct OverlayerView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openWindow) private var openWindow
    @EnvironmentObject private var appState: AppState

    @State private var selectionRect: CGRect = .zero
    @State private var selected = false
    @State private var activeHandle: ResizeHandle = .none
    @State private var lastMouseLocation: CGPoint?
    @State private var isShowActionbar = false

    // 激活矩形
    @State private var isDragging = false
    @State private var dragStart = CGPoint.zero
    @State private var dragOffset = CGSize.zero

    // 用于存储所有可拖动形状的数据
    @State private var annotations: [Annotation] = []
    // 修改为计算属性
    var showActiveFrame: Bool {
        return dragStart != .zero && dragOffset != .zero && appState.annotationType != .none && appState.cropRect != .zero
    }

    //
    var selectionAreaEditable: Bool {
        return selectionRect != .zero && appState.annotationType == .none && annotations.isEmpty
    }

    var activeAnnotation: Annotation? {
        if showActiveFrame {
            return Annotation(
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
        } else {
            return annotations.first { $0.active } ?? annotations.last
        }
    }

    var stepSelect: Bool {
        return appState.annotationType == .none && annotations.isEmpty
    }

    let controlPointSize: CGFloat = 10.0
    let controlPointColor: Color = .yellow

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Canvas { context, size in

                    // 绘制所有未标注
                    for annotation in annotations {
                        switch annotation.type {
                        case .rect:
                            drawRect(context: context, annotation: annotation, size: size)
                        case .text:
                            drawText(context: context, annotation: annotation, size: size)
                        case .arrow:
                            drawArrow(context: context, annotation: annotation, size: size)
                        case .none:
                            continue
                        }
                    }
                }
                // 背景层
                Color.clear
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture(minimumDistance: 4, coordinateSpace: .named(Keys.coordinate))
                            .onChanged { value in
                                handleDragGestureChanged(value)
                            }
                            .onEnded { value in
                                handleDragGestureEnded(value)
                            }
                    )

                // 选择框层
                if selectionRect != .zero {
                    SelectionAreaView(editable: selectionAreaEditable, frame: selectionRect, onUpdateFrame: { offset, size in
                        selectionRect.origin.x += offset.width
                        selectionRect.origin.y += offset.height
                        selectionRect.size.width += size.width
                        selectionRect.size.height += size.height
                        appState.cropRect = selectionRect
                    }).position(x: selectionRect.midX, y: selectionRect.midY)

                    if !isDragging {
                        ActionBarView()
                            .frame(width: 500, height: 36)
                            .position(x: selectionRect.maxX - 250, y: selectionRect.maxY + 36)
                    }
                }

                if let ann = activeAnnotation {
                    ActiveAnnotationView(annotation: ann, onUpdateFrame: { offset, size in
                        if let index = annotations.firstIndex(where: { $0.id == ann.id }) {
                            annotations[index].frame.origin.x += offset.width
                            annotations[index].frame.origin.y += offset.height
                            annotations[index].frame.size.width += size.width
                            annotations[index].frame.size.height += size.height
                        }
                    })
                    .position(x: ann.frame.midX, y: ann.frame.midY)
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .background(Color.gray.opacity(0.5))
            .coordinateSpace(.named(Keys.coordinate))
        }
    }

    private func handleDragGestureChanged(_ value: DragGesture.Value) {
        if !isDragging {
            dragStart = value.startLocation
            dragOffset = .zero
            isDragging = true
        }

        // 实时更新位置
        dragOffset = value.translation
        if stepSelect {
            selectionRect.origin = dragStart
            selectionRect.size = dragOffset
        }
    }

    private func handleDragGestureEnded(_ event: DragGesture.Value) {
        if stepSelect {
            selectionRect.origin = dragStart
            selectionRect.size = dragOffset
            appState.cropRect = selectionRect
        } else {
            annotations.append(Annotation(
                type: appState.annotationType,
                frame: CGRect(
                    x: dragStart.x,
                    y: dragStart.y,
                    width: abs(dragOffset.width),
                    height: abs(dragOffset.height)
                ),
                start: dragStart,
                offset: dragOffset
            ))
        }
        dragStart = .zero
        dragOffset = .zero
        isDragging = false
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
        let start = annotation.start
        let end = CGPoint(x: start.x + annotation.offset.width, y: start.y + annotation.offset.height)

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
  
    private func saveCanvas() {
         let renderer = ImageRenderer(content: self)
        if let cgImage = renderer.cgImage {
            appState.annotationImage = cgImage
            // 保存
            logger.info("保存图片成功")
        } else {
            logger.error("保存图片失败")
        }
    }
}
