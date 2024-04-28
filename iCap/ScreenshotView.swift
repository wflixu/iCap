//
//  ScreenshotView.swift
//  iCap
//
//  Created by 李旭 on 2024/4/28.
//

import SwiftUI


class ScreenshotWindow: NSWindow {
    let overlayView = ScreenshotOverlayView()

    override init(contentRect: NSRect, styleMask style: NSWindow.StyleMask, backing bufferingType: NSWindow.BackingStoreType, defer flag: Bool) {
        super.init(contentRect: contentRect, styleMask: style, backing: bufferingType, defer: flag)

        self.isOpaque = false
        self.level = .statusBar
        self.backgroundColor = NSColor.clear
        self.collectionBehavior = [.canJoinAllSpaces, .fullScreenPrimary]
        self.isReleasedWhenClosed = false
        self.contentView = overlayView
        NSEvent.addLocalMonitorForEvents(matching: NSEvent.EventTypeMask.keyDown, handler: myKeyDownEvent)
    }

    func myKeyDownEvent(event: NSEvent) -> NSEvent {
        if event.keyCode == 53 {
            close()
            for w in NSApplication.shared.windows.filter({ $0.title == WindowTitle.actionbar.desc }) {
                w.close()
            }
        }
        return event
    }
    
    func showActionBar() {
        guard let screen = SCContext.getScreenWithMouse() else { return }
        let wX = (screen.frame.width - 510) / 2
        let wY = screen.visibleFrame.minY + 36
        var window = NSWindow()
        let contentView = NSHostingView(rootView: ActionBar())
        contentView.frame = NSRect(x: wX, y: wY, width: 510, height: 36)
        print("--- \(contentView.frame.height) ww\(contentView.frame.width)")
        window = NSWindow(contentRect: contentView.frame, styleMask: [], backing: .buffered, defer: false)
        window.level = .screenSaver
        window.title = WindowTitle.actionbar.desc
        window.standardWindowButton(.closeButton)?.isHidden = true
        window.standardWindowButton(.miniaturizeButton)?.isHidden = true
        window.standardWindowButton(.zoomButton)?.isHidden = true
        window.contentView = contentView
        window.titleVisibility = .hidden
        window.isReleasedWhenClosed = false
        window.titlebarAppearsTransparent = true
        window.isMovableByWindowBackground = true
        window.makeKeyAndOrderFront(self)
    }
}

class ScreenshotOverlayView: NSView {
    var selectionRect: NSRect?
    var initialLocation: NSPoint?
    var maskLayer: CALayer?
    var dragIng: Bool = false
    var activeHandle: ResizeHandle = .none
    var lastMouseLocation: NSPoint?

    let controlPointSize: CGFloat = 10.0
    let controlPointColor: NSColor = NSColor.systemYellow

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
//        selectionRect = NSRect(x: (self.frame.width - 600) / 2, y: (self.frame.height - 450) / 2 + 70, width: 600, height: 450)
//        SCContext.screenArea = selectionRect
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        NSColor.black.withAlphaComponent(0.5).setFill()
        dirtyRect.fill()

        // Draw selection rectangle
        if let rect = selectionRect {
            let dashPattern: [CGFloat] = [4.0, 4.0]
            let dashedBorder = NSBezierPath(rect: rect)
            dashedBorder.lineWidth = 4.0
            dashedBorder.setLineDash(dashPattern, count: 2, phase: 0.0)
            NSColor.white.setStroke()
            dashedBorder.stroke()
            NSColor.init(white: 1, alpha: 0.01).setFill()
            __NSRectFill(rect)
            // Draw control points
            for handle in ResizeHandle.allCases {
                if let point = controlPointForHandle(handle, inRect: rect) {
                    let controlPointRect = NSRect(origin: point, size: CGSize(width: controlPointSize, height: controlPointSize))
                    let controlPointPath = NSBezierPath(ovalIn: controlPointRect)
                    controlPointColor.setFill()
                    controlPointPath.fill()
                }
            }
        }
    }
//
    func handleForPoint(_ point: NSPoint) -> ResizeHandle {
        guard let rect = selectionRect else { return .none }

        for handle in ResizeHandle.allCases {
            if let controlPoint = controlPointForHandle(handle, inRect: rect), NSRect(origin: controlPoint, size: CGSize(width: controlPointSize, height: controlPointSize)).contains(point) {
                return handle
            }
        }
        return .none
    }

    func controlPointForHandle(_ handle: ResizeHandle, inRect rect: NSRect) -> NSPoint? {
        switch handle {
        case .topLeft:
            return NSPoint(x: rect.minX - controlPointSize / 2 - 1, y: rect.maxY - controlPointSize / 2 + 1)
        case .top:
            return NSPoint(x: rect.midX - controlPointSize / 2, y: rect.maxY - controlPointSize / 2 + 1)
        case .topRight:
            return NSPoint(x: rect.maxX - controlPointSize / 2 + 1, y: rect.maxY - controlPointSize / 2 + 1)
        case .right:
            return NSPoint(x: rect.maxX - controlPointSize / 2 + 1, y: rect.midY - controlPointSize / 2)
        case .bottomRight:
            return NSPoint(x: rect.maxX - controlPointSize / 2 + 1, y: rect.minY - controlPointSize / 2 - 1)
        case .bottom:
            return NSPoint(x: rect.midX - controlPointSize / 2, y: rect.minY - controlPointSize / 2 - 1)
        case .bottomLeft:
            return NSPoint(x: rect.minX - controlPointSize / 2 - 1, y: rect.minY - controlPointSize / 2 - 1)
        case .left:
            return NSPoint(x: rect.minX - controlPointSize / 2 - 1, y: rect.midY - controlPointSize / 2)
        case .none:
            return nil
        }
    }

    override func mouseDown(with event: NSEvent) {
        let location = convert(event.locationInWindow, from: nil)
        initialLocation = location
        lastMouseLocation = location
        activeHandle = handleForPoint(location)
        if let rect = selectionRect, NSPointInRect(location, rect) { dragIng = true }
        needsDisplay = true
        SCContext.closeActionbarWindow()
    }

    override func mouseDragged(with event: NSEvent) {
        guard var initialLocation = initialLocation else { return }
        let currentLocation = convert(event.locationInWindow, from: nil)
        if activeHandle != .none {

            // Calculate new rectangle size and position
            var newRect = selectionRect ?? CGRect.zero

            // Get last mouse location
            let lastLocation = lastMouseLocation ?? currentLocation

            let deltaX = currentLocation.x - lastLocation.x
            let deltaY = currentLocation.y - lastLocation.y

            switch activeHandle {
            case .topLeft:
                newRect.origin.x = min(newRect.origin.x + newRect.size.width - 20, newRect.origin.x + deltaX)
                newRect.size.width = max(20, newRect.size.width - deltaX)
                newRect.size.height = max(20, newRect.size.height + deltaY)
            case .top:
                newRect.size.height = max(20, newRect.size.height + deltaY)
            case .topRight:
                newRect.size.width = max(20, newRect.size.width + deltaX)
                newRect.size.height = max(20, newRect.size.height + deltaY)
            case .right:
                newRect.size.width = max(20, newRect.size.width + deltaX)
            case .bottomRight:
                newRect.origin.y = min(newRect.origin.y + newRect.size.height - 20, newRect.origin.y + deltaY)
                newRect.size.width = max(20, newRect.size.width + deltaX)
                newRect.size.height = max(20, newRect.size.height - deltaY)
            case .bottom:
                newRect.origin.y = min(newRect.origin.y + newRect.size.height - 20, newRect.origin.y + deltaY)
                newRect.size.height = max(20, newRect.size.height - deltaY)
            case .bottomLeft:
                newRect.origin.y = min(newRect.origin.y + newRect.size.height - 20, newRect.origin.y + deltaY)
                newRect.origin.x = min(newRect.origin.x + newRect.size.width - 20, newRect.origin.x + deltaX)
                newRect.size.width = max(20, newRect.size.width - deltaX)
                newRect.size.height = max(20, newRect.size.height - deltaY)
            case .left:
                newRect.origin.x = min(newRect.origin.x + newRect.size.width - 20, newRect.origin.x + deltaX)
                newRect.size.width = max(20, newRect.size.width - deltaX)
            default:
                break
            }
            self.selectionRect = newRect
            initialLocation = currentLocation // Update initial location for continuous dragging
            lastMouseLocation = currentLocation // Update last mouse location
        } else {
            if dragIng {
                dragIng = true
                // 计算移动偏移量
                let deltaX = currentLocation.x - initialLocation.x
                let deltaY = currentLocation.y - initialLocation.y

                // 更新矩形位置
                let x = self.selectionRect?.origin.x
                let y = self.selectionRect?.origin.y
                let w = self.selectionRect?.size.width
                let h = self.selectionRect?.size.height
                self.selectionRect?.origin.x = min(max(0.0, x! + deltaX), self.frame.width - w!)
                self.selectionRect?.origin.y = min(max(0.0, y! + deltaY), self.frame.height - h!)
                initialLocation = currentLocation
            } else {
                //dragIng = false
                // 创建新矩形
                let origin = NSPoint(x: min(initialLocation.x, currentLocation.x), y: min(initialLocation.y, currentLocation.y))
                let size = NSSize(width: abs(currentLocation.x - initialLocation.x), height: abs(currentLocation.y - initialLocation.y))
                self.selectionRect = NSRect(origin: origin, size: size)
                //initialLocation = currentLocation
            }
            self.initialLocation = initialLocation
        }
        lastMouseLocation = currentLocation
        needsDisplay = true
    }
//
    override func mouseUp(with event: NSEvent) {
        initialLocation = nil
        activeHandle = .none
        dragIng = false
        if let rect = selectionRect {
            SCContext.screenArea = rect
           
            
            Task {
                try await Task.sleep(nanoseconds: UInt64(1.0 * 1e8))
                showActionBar(rect)
            }
            
            //let rectArray = [Int(rect.origin.x), Int(rect.origin.y), Int(rect.size.width), Int(rect.size.height)]
            //ud.setValue(rectArray, forKey: "screenArea")
        }
    }
    
    func showActionBar(_ ns: NSRect?) {
        
        var window = NSWindow()
        let contentView = NSHostingView(rootView: ActionBar())
        contentView.frame = SCContext.getActionBarPosition(ns)
        window = NSWindow(contentRect: contentView.frame, styleMask: [], backing: .buffered, defer: false)
        window.level = .screenSaver
        window.title = WindowTitle.actionbar.desc
        window.standardWindowButton(.closeButton)?.isHidden = true
        window.standardWindowButton(.miniaturizeButton)?.isHidden = true
        window.standardWindowButton(.zoomButton)?.isHidden = true
        window.contentView = contentView
        window.titleVisibility = .hidden
        window.isReleasedWhenClosed = false
        window.titlebarAppearsTransparent = true
        window.isMovableByWindowBackground = true
        window.makeKeyAndOrderFront(self)
    }
}

#Preview {
    ScreenshotOverlayView()
}
