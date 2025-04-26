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

    var step: StepStatus {
        if appState.annotationType != .none || !annotations.isEmpty {
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

                if step == .drawing {
                    CanvasView(frame: selectionRect)
                        .frame(width: selectionRect.width, height: selectionRect.height)
                        .position(x: selectionRect.midX, y: selectionRect.midY)
                        .zIndex(100)
                }

//
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .background(Color.gray.opacity(0.5))
            .coordinateSpace(.named(Keys.coordinate))
            .onReceive(EventBus.shared.publisher(for: "savedAnno")) { data in
                if let id = data as? String {
                    saveImage(id);
                }
            }
        }
    }

    private func saveImage(_ key: String) {
        logger.info("保存图片,,, \(key)")
        appState.saveImage()
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
