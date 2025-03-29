//
//  SCContext.swift
//  iCap
//
//  Created by 李旭 on 2024/4/26.
//

import AppKit
import AVFAudio
import AVFoundation
import Foundation
import ScreenCaptureKit
import UserNotifications

enum SCContext {
    static var screenImage: CGImage?
    static var screenArea: NSRect?

    static func getScreenWithMouse() -> NSScreen? {
        let mouseLocation = NSEvent.mouseLocation
        let screenWithMouse = NSScreen.screens.first(where: { NSMouseInRect(mouseLocation, $0.frame, false) })
        return screenWithMouse
    }

    static func closeWindows() {
        for w in NSApplication.shared.windows.filter({ $0.title == WindowTitle.actionbar.desc || $0.title == WindowTitle.overlay.desc }) {
            w.close()
        }
    }

    static func closeActionbarWindow() {
        for w in NSApplication.shared.windows.filter({ $0.title == WindowTitle.actionbar.desc }) {
            w.close()
        }
    }

    static func showMainWindow() {
        print("showMainWindow ")
        for w in NSApplication.shared.windows {
            print("the window \(w.title)-- will show")

            switch w.title {
                case "iCap":
                    print("start show window")
                case "Connection Doctor":
//                    w.level = .floating
                    w.makeKeyAndOrderFront(nil)

//                    NotificationCenter.default.addObserver(
//                        forName: NSWindow.didResignKeyNotification,
//                        object: w,
//                        queue: .main
//                    ) { _ in
//                        // 窗口失去焦点时，恢复为 .normal
//                        w.level = .normal
//                    }
                default:
                    print("no action at window: \(w.title) ")
            }
//            if w.title == "iCap" {
//                print("start show window")
//
            ////                w.windowController?.showWindow(nil)
//
//            } else {
//                w.level = .floating
//                w.makeKeyAndOrderFront(nil)
//            }
        }
    }

    static func showAreaSelectWindow() {
        guard let screen = SCContext.getScreenWithMouse() else { return }
        let screenshotWindow = ScreenshotWindow(contentRect: screen.frame, styleMask: [], backing: .buffered, defer: false)
        screenshotWindow.title = WindowTitle.overlay.desc
        screenshotWindow.makeKeyAndOrderFront(nil)
        screenshotWindow.orderFrontRegardless()
    }

    static func getActionBarPosition(_ select: NSRect?) -> NSRect {
        if let screen = SCContext.getScreenWithMouse() {
            if let screenArea = select {
                print("screenArea ----\(screenArea) ")
                return NSRect(x: screenArea.minX, y: screenArea.minY - 46, width: screenArea.width, height: 36)
            } else {
                let wX = (screen.frame.width - 510) / 2
                let wY = screen.visibleFrame.minY + 36
                return NSRect(x: wX, y: wY, width: 510, height: 36)
            }
        } else {
            print("----")
            return NSRect()
        }
    }

    static func getImageSavePath() -> String {
        // 读取 UserDefaults 中存储的路径
        let savePath = UserDefaults.standard.string(forKey: "imageSavePath") ?? "/Users/"
        return savePath
    }

    static func getScreenImage() async throws -> CGImage {
        // 检查屏幕录制权限
        guard CGPreflightScreenCaptureAccess() else {
            throw AppError.permissionDenied
        }
        
        let availableContent = try await SCShareableContent.current
        
        guard let display = availableContent.displays.first else {
            throw AppError.noDisplayFound
        }
        
        let contentFilter = SCContentFilter(display: display,
                                          excludingApplications: [], 
                                          exceptingWindows: [])
        
        let configuration = SCStreamConfiguration()
        if let screen = getScreenWithMouse() {
            configuration.width = Int(screen.frame.width * screen.backingScaleFactor)
            configuration.height = Int(screen.frame.height * screen.backingScaleFactor)
            configuration.minimumFrameInterval = CMTime(value: 1, timescale: 60)
            configuration.pixelFormat = kCVPixelFormatType_32BGRA
            configuration.showsCursor = true
        }
        
        do {
            let image = try await SCScreenshotManager.captureImage(
                contentFilter: contentFilter,
                configuration: configuration
            )
            SCContext.screenImage = image
            return image
        } catch {
            throw AppError.captureFailed(error.localizedDescription)
        }
    }

    static func saveImage(_ to: ImageSaveTo = .pasteboard) -> Data? {
        if let rect = SCContext.screenArea, let cgimage = SCContext.screenImage {
            print("rect\(rect.height) \(rect.width) x:\(rect.minX) y: \(rect.minY)  origin:\(rect.origin.x) \(rect.origin.y)")
            print("cgimg\(cgimage.height) \(cgimage.width)")
            let clipRect = CGRect(x: rect.minX, y: CGFloat(cgimage.height) - rect.minY - rect.height, width: rect.width, height: rect.height)

            let newimg = cgimage.cropping(to: clipRect)!
            let bitmap = NSBitmapImageRep(cgImage: newimg)
            let pngData = bitmap.representation(using: .png, properties: [:])
//            let filePath = SCContext.getImageSavePath() + "/" + Util.getDatetimeFileName()

            if let data = pngData {
                if to == .file {
                    // 获取应用沙盒的 Documents 目录

                    return data
                } else {
                    let pb = NSPasteboard.general
                    pb.clearContents()

                    let saveRes = pb.setData(data, forType: .png)
                    print("save data in pastboard is \(saveRes)")
                }
//
            }
        } else {
            print("screenArea,cgimage  not ")
        }

        return nil
    }
}

enum AppError: Error {
    case notDisplay
    case permissionDenied
    case noDisplayFound
    case captureFailed(String)
}
