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
import OSLog
import ScreenCaptureKit
import UserNotifications
import CoreImage
import CoreGraphics
import CoreImage.CIFilterBuiltins


let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "SCContext")

class SCContext {
    static var screenImage: CGImage?
    static var screenArea: NSRect?

    static func getScreenWithMouse() -> NSScreen? {
        let mouseLocation = NSEvent.mouseLocation
        let screenWithMouse = NSScreen.screens.first(where: { NSMouseInRect(mouseLocation, $0.frame, false) })
        return screenWithMouse
    }

    static func closeOverlayWindow() {
        for w in NSApplication.shared.windows.filter({ $0.title == AppWinsInfo.overlayer.desc }) {
            w.close()
        }
    }

    static func setOverlayWindowLevel(_ level: NSWindow.Level) {
        for w in NSApplication.shared.windows.filter({ $0.title == AppWinsInfo.overlayer.desc }) {
            w.level = level
        }
    }

    static func showMainWindow() {
        for w in NSApplication.shared.windows {
            switch w.title {
            case "iCap":
                print("start show window")
            case "Connection Doctor":
                w.makeKeyAndOrderFront(nil)
            default:
                print("no action at window: \(w.title)")
            }
        }
    }

    static func showAreaSelectWindow() {}

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
        let savePath = UserDefaults.group.string(forKey: "imageSavePath") ?? "/Users/"
        return savePath
    }

    static func getScreenImage() async throws -> CGImage {
        logger.info("getScreenImage")

        let availableContent = try await SCShareableContent.current

        guard let display = availableContent.displays.first else {
            logger.error("noDisplayFound")
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
        } else {
            logger.error("notDisplay")
        }

        do {
            let image = try await SCScreenshotManager.captureImage(
                contentFilter: contentFilter,
                configuration: configuration
            )
            SCContext.screenImage = image
            return image
        } catch {
            logger.error("captureFailed: \(error.localizedDescription)")
            throw AppError.captureFailed(error.localizedDescription)
        }
    }
    
    
    static func processImageWithEffects(
        inputImage: CGImage,
        cornerRadius: CGFloat = 10,
        shadowColor: NSColor = .black,
        shadowOffset: CGSize = .init(width: 0 , height: 10),
        shadowRadius: CGFloat = 15,
        shadowOpacity: CGFloat = 0.3
    ) -> CGImage? {
        // 创建透明画布
        let imageSize = CGSize(width: inputImage.width, height: inputImage.height)
        let effectiveRect = CGRect(
            x: abs(shadowOffset.width) + shadowRadius,
            y: abs(shadowOffset.height) + shadowRadius,
            width: imageSize.width,
            height: imageSize.height
        )
        
        let canvasSize = CGSize(
            width: effectiveRect.width + shadowRadius * 2,
            height: effectiveRect.height + shadowRadius * 2
        )
        
        guard let context = CGContext(
            data: nil,
            width: Int(canvasSize.width),
            height: Int(canvasSize.height),
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else { return nil }
        
        // 绘制阴影
        let shadowRect = CGRect(
            x: effectiveRect.origin.x + shadowOffset.width,
            y: effectiveRect.origin.y + shadowOffset.height,
            width: effectiveRect.width,
            height: effectiveRect.height
        )
        
        context.setShadow(
            offset: shadowOffset,
            blur: shadowRadius,
            color: shadowColor.withAlphaComponent(shadowOpacity).cgColor
        )
        
        // 创建圆角路径
        let path = NSBezierPath(
            roundedRect: shadowRect,
            xRadius: cornerRadius,
            yRadius: cornerRadius
        ).cgPath
        
        context.addPath(path)
        context.fillPath()
        
        // 裁剪圆角区域
        context.addPath(path)
        context.clip()
        
        // 绘制原图
        let drawRect = CGRect(
            x: effectiveRect.origin.x,
            y: effectiveRect.origin.y,
            width: imageSize.width,
            height: imageSize.height
        )
        
        context.draw(inputImage, in: drawRect)
        
        // 生成最终图像
        return context.makeImage()
    }
    
    

    static func saveImage(_ to: ImageSaveTo = .pasteboard) -> Data? {
        if let rect = SCContext.screenArea, let cgimage = SCContext.screenImage {
            print("rect\(rect.height) \(rect.width) x:\(rect.minX) y: \(rect.minY)  origin:\(rect.origin.x) \(rect.origin.y)")
            print("cgimg\(cgimage.height) \(cgimage.width)")
            // 修正y轴坐标计算，确保截取区域与选择区域一致
            let clipRect = CGRect(x: rect.minX,
                                  y: rect.minY,
                                  width: rect.width,
                                  height: rect.height)

            let cropimg = cgimage.cropping(to: clipRect)!
            let effectimg = SCContext.processImageWithEffects(inputImage: cropimg)!
            let bitmap = NSBitmapImageRep(cgImage: effectimg)
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
