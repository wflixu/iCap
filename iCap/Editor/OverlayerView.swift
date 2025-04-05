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
    @State private var selectionRect: CGRect?
    @State private var initialLocation: CGPoint?
    @State private var dragIng = false
    @State private var activeHandle: ResizeHandle = .none
    @State private var lastMouseLocation: CGPoint?
    @State private var isShowActionbar = false
    
    let controlPointSize: CGFloat = 10.0
    let controlPointColor: Color = .yellow
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 背景层
                Color.clear
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                handleDrag(value: value, in: geometry)
                            }
                            .onEnded { _ in
                                handleDragEnd()
                            }
                    )
                
                // 选择框层
                if let rect = selectionRect {
                    Rectangle()
                        .stroke(style: StrokeStyle(lineWidth: 2, dash: [4]))
                        .foregroundColor(.white)
                        .frame(width: rect.width, height: rect.height)
                        .position(x: rect.midX, y: rect.midY)
                        
                    // 控制点
                    ForEach(ResizeHandle.allCases, id: \.self) { handle in
                        if let point = controlPointForHandle(handle, inRect: rect) {
                            Circle()
                                .fill(controlPointColor)
                                .frame(width: controlPointSize, height: controlPointSize)
                                .position(x: point.x + controlPointSize/2 , y: point.y + controlPointSize/2)
                        }
                    }
                }
                // isShowActionbar
                if isShowActionbar {
                    if let rect = selectionRect {
                        ActionBarView()
                            .frame(width: 500, height: 36)
                            .position(x: rect.maxX - 250, y: rect.maxY + 36)
                    }
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .background(Color.gray.opacity(0.5))
        }
    }
    
    private func handleDrag(value: DragGesture.Value, in geometry: GeometryProxy) {
        let location = value.location
        
        if initialLocation == nil {
            initialLocation = location
            lastMouseLocation = location
            activeHandle = handleForPoint(location)
            if let rect = selectionRect, rect.contains(location) {
                dragIng = true
            }
            return
        }
        
        guard let initialLocation = initialLocation else { return }
        
        if activeHandle != .none {
            var newRect = selectionRect ?? .zero
            let lastLocation = lastMouseLocation ?? location
            
            let deltaX = location.x - lastLocation.x
            let deltaY = location.y - lastLocation.y
            
            switch activeHandle {
            case .topLeft:
                newRect.origin.x = min(newRect.origin.x + newRect.width - 20, newRect.origin.x + deltaX)
                newRect.size.width = max(20, newRect.width - deltaX)
                newRect.size.height = max(20, newRect.height + deltaY)
            case .top:
                newRect.size.height = max(20, newRect.height + deltaY)
            case .topRight:
                newRect.size.width = max(20, newRect.width + deltaX)
                newRect.size.height = max(20, newRect.height + deltaY)
            case .right:
                newRect.size.width = max(20, newRect.width + deltaX)
            case .bottomRight:
                newRect.origin.y = min(newRect.origin.y + newRect.height - 20, newRect.origin.y + deltaY)
                newRect.size.width = max(20, newRect.width + deltaX)
                newRect.size.height = max(20, newRect.height - deltaY)
            case .bottom:
                newRect.origin.y = min(newRect.origin.y + newRect.height - 20, newRect.origin.y + deltaY)
                newRect.size.height = max(20, newRect.height - deltaY)
            case .bottomLeft:
                newRect.origin.y = min(newRect.origin.y + newRect.height - 20, newRect.origin.y + deltaY)
                newRect.origin.x = min(newRect.origin.x + newRect.width - 20, newRect.origin.x + deltaX)
                newRect.size.width = max(20, newRect.width - deltaX)
                newRect.size.height = max(20, newRect.height - deltaY)
            case .left:
                newRect.origin.x = min(newRect.origin.x + newRect.width - 20, newRect.origin.x + deltaX)
                newRect.size.width = max(20, newRect.width - deltaX)
            default:
                break
            }
            
            selectionRect = newRect
            lastMouseLocation = location
        } else {
            if dragIng {
                let deltaX = location.x - initialLocation.x
                let deltaY = location.y - initialLocation.y
                
                if var rect = selectionRect {
                    rect.origin.x = min(max(0, rect.origin.x + deltaX), geometry.size.width - rect.width)
                    rect.origin.y = min(max(0, rect.origin.y + deltaY), geometry.size.height - rect.height)
                    selectionRect = rect
                }
            } else {
                let origin = CGPoint(x: min(initialLocation.x, location.x),
                                     y: min(initialLocation.y, location.y))
                let size = CGSize(width: abs(location.x - initialLocation.x),
                                  height: abs(location.y - initialLocation.y))
                selectionRect = CGRect(origin: origin, size: size)
            }
        }
    }
    
    private func handleDragEnd() {
        initialLocation = nil
        activeHandle = .none
        dragIng = false
        
        if let rect = selectionRect {
            SCContext.screenArea = rect
            
            Task {
                try await Task.sleep(nanoseconds: UInt64(1.0 * 1e8))
                showActionBar(rect)
            }
        }
    }
    
    private func showActionBar(_ rect: CGRect) {
        // 实现显示操作栏的逻辑
        isShowActionbar = true
    }
    
    private func handleForPoint(_ point: CGPoint) -> ResizeHandle {
        guard let rect = selectionRect else { return .none }
        
        for handle in ResizeHandle.allCases {
            if let controlPoint = controlPointForHandle(handle, inRect: rect),
               CGRect(origin: controlPoint,
                      size: CGSize(width: controlPointSize, height: controlPointSize)).contains(point)
            {
                return handle
            }
        }
        return .none
    }
    
    private func controlPointForHandle(_ handle: ResizeHandle, inRect rect: CGRect) -> CGPoint? {
        switch handle {
        case .topLeft:
            return CGPoint(x: rect.minX - controlPointSize / 2 - 1, y: rect.maxY - controlPointSize / 2 + 1)
        case .top:
            return CGPoint(x: rect.midX - controlPointSize / 2, y: rect.maxY - controlPointSize / 2 + 1)
        case .topRight:
            return CGPoint(x: rect.maxX - controlPointSize / 2 + 1, y: rect.maxY - controlPointSize / 2 + 1)
        case .right:
            return CGPoint(x: rect.maxX - controlPointSize / 2 + 1, y: rect.midY - controlPointSize / 2)
        case .bottomRight:
            return CGPoint(x: rect.maxX - controlPointSize / 2 + 1, y: rect.minY - controlPointSize / 2 - 1)
        case .bottom:
            return CGPoint(x: rect.midX - controlPointSize / 2, y: rect.minY - controlPointSize / 2 - 1)
        case .bottomLeft:
            return CGPoint(x: rect.minX - controlPointSize / 2 - 1, y: rect.minY - controlPointSize / 2 - 1)
        case .left:
            return CGPoint(x: rect.minX - controlPointSize / 2 - 1, y: rect.midY - controlPointSize / 2)
        case .none:
            return nil
        }
    }
}
