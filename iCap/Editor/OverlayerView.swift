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
        return selectionRect != .zero && appState.annotationType == .none && appState.annotations.isEmpty
    }

    var step: StepStatus {
        if appState.annotationType != .none || !appState.annotations.isEmpty {
            return .drawing
        } else {
            return .selecting
        }
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
            return appState.annotations.first { $0.active } ?? appState.annotations.last
        }
    }

    var stepSelect: Bool {
        return appState.annotationType == .none && appState.annotations.isEmpty
    }

    let controlPointSize: CGFloat = 10.0
    let controlPointColor: Color = .yellow

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 显示截图
                if let cgImage = appState.screenImage {
                    Image(decorative: cgImage, scale: 1.0)
                        .resizable()
                        .scaledToFit()
                }
                // 背景层
               
                Color(.sRGB, red: 0.8, green: 0.8, blue: 0.8, opacity: 0.5)
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

                if step == .drawing  {
                    CanvasView(frame: selectionRect, annotations: appState.annotations)
                        .border(Color.blue, width: 2)
                        .frame(width: selectionRect.width, height: selectionRect.height)
                        .position(x: selectionRect.midX, y: selectionRect.midY)
                        .zIndex(100)
                }

//
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .background(Color.gray.opacity(0.5))
            .coordinateSpace(.named(Keys.coordinate))
            .onReceive(EventBus.shared.observe(SavedAnno.self)) { event in
                saveImage(event.data)
            }
            .onReceive(EventBus.shared.observe(SaveAll.self)) { event in
                saveImageAll(event.data)
            }
            .onReceive(EventBus.shared.observe(SaveDrawing.self)) { _ in
                saveCanvas()
            }
        }
    }
    
    private func saveCanvas() {
        logger.info("保存画布")
        if appState.annotations.isEmpty {
            logger.warning("没有标注数据")
            EventBus.shared.post(SavedAnno(data: "savedAnno"))
            return
        }
        // ImageRenderer用于将SwiftUI视图渲染为图像
        // 需要设置具体的尺寸，否则会使用视图的理想尺寸，可能导致比例失调
        let renderer = ImageRenderer(content: CanvasView(frame: selectionRect, annotations: appState.annotations).frame(width: selectionRect.width, height: selectionRect.height))
        // 设置明确的渲染尺寸，使用frame的大小
        renderer.proposedSize = ProposedViewSize(width: selectionRect.width, height: selectionRect.height)

        if let cgImage = renderer.cgImage {
            logger.info("渲染图像尺寸: 宽度 - \(cgImage.width), 高度 - \(cgImage.height)")
            appState.annotationImage = cgImage
            // 保存
            logger.info("保存图片成功")
            EventBus.shared.post(SavedAnno(data: "savedAnno"))
        } else {
            logger.error("保存图片失败")
        }
    }

    private func saveImage(_ key: String) {
        logger.info("保存图片,,, \(key)")
        appState.saveImageAll()
    }
    private func saveImageAll(_ key: String) {
        logger.info("保存图片复合,,, \(key)")
        appState.saveImageAll()
    }

    private func handleDragGestureChanged(_ value: DragGesture.Value) {
        if step == .drawing {
            return
        }

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
        if step == .drawing {
            return
        }

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
}
