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
        for w in NSApplication.shared.windows.filter({ $0.title == "iCap" }) {
            print("the window \(w.title) will show")
            w.makeKeyAndOrderFront(nil)
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
                return NSRect(x: screenArea.minX, y: screenArea.minY - 36, width: screenArea.width, height: 36)
            } else {
                let wX = (screen.frame.width - 510) / 2
                let wY = screen.visibleFrame.minY + 36
                return NSRect(x: wX, y: wY, width: 510, height: 36)
            }
        } else {
            return NSRect()
        }
    }

    static func getScreenImage() async throws -> CGImage {
        let availableContent = try? await SCShareableContent.current

        guard let availableContent = availableContent,
              let display = availableContent.displays.first
        else {
            print("not display")
            throw AppError.notDisplay
        }

        let myContentFilter = SCContentFilter(display: display,
                                              excludingApplications: [], exceptingWindows: [])
        let myConfiguration = SCStreamConfiguration()
        if let screenWithMouse = SCContext.getScreenWithMouse() {
            myConfiguration.width = Int(screenWithMouse.frame.width)
            myConfiguration.height = Int(screenWithMouse.frame.height)
        }

        if let res = try? await SCScreenshotManager.captureImage(contentFilter: myContentFilter, configuration: myConfiguration) {
            SCContext.screenImage = res

            return res
        } else {
            throw AppError.notDisplay
        }
    }

    static func saveImage(_ to: ImageSaveTo = .pasteboard) {
        if let rect = SCContext.screenArea, let cgimage = SCContext.screenImage {
            print("rect\(rect.height) \(rect.width) x:\(rect.minX) y: \(rect.minY)  origin:\(rect.origin.x) \(rect.origin.y)")
            print("cgimg\(cgimage.height) \(cgimage.width)")
            let clipRect = CGRect(x: rect.minX, y: CGFloat(cgimage.height) - rect.minY - rect.height, width: rect.width, height: rect.height)

            let newimg = cgimage.cropping(to: clipRect)!
            let bitmap = NSBitmapImageRep(cgImage: newimg)
            let pngData = bitmap.representation(using: .png, properties: [:])
            let filePath = "/Users/lixu/Desktop/" + Util.getDatetimeFileName()

            if let data = pngData {
                if to == .file {
                    do {
                        try data.write(to: URL(fileURLWithPath: filePath))
                        print("Image saved successfully at: \(filePath)")
                    } catch {
                        print("Error saving image: \(error)")
                    }
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
    }
}

enum AppError: Error {
    case notDisplay
}
