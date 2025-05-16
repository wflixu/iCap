//
//  AppState.swift
//  iCap
//
//  Created by 李旭 on 2025/1/17.
//

import AppKit
import Combine
import KeyboardShortcuts
import ScreenCaptureKit

@MainActor
class AppState: ObservableObject {
    @AppLog(category: "AppState")
    private var logger

    @Published
    var isUnicornMode: Bool = false

    // overlayer is show
    @Published
    var isShow: Bool = false

    @Published
    var imageSaveTo: ImageSaveTo = .pasteboard

    @Published
    var annotationType: AnnotationType = .none

    @Published
    var annotations: [Annotation] = []

    @Published
    var screenImage: CGImage?

    @Published
    var annotationImage: CGImage?
    // 如果点击的固定，需要保存裁减后的状态

    @Published
    var showPin: Bool = false

    @Published
    var resultImage: CGImage?

    @Published
    var savingDrawing: Bool = false

    @Published
    var cropRect: CGRect = .zero

    static var share = AppState()

    func setImageSaveTo(_ saveTo: ImageSaveTo) {
        imageSaveTo = saveTo
    }

    func toggleAnnotationType(_ type: AnnotationType) {
        if annotationType == type {
            annotationType = .none
        } else {
            annotationType = type
        }
    }

    func getScreenWithMouse() -> NSScreen? {
        let mouseLocation = NSEvent.mouseLocation
        let screenWithMouse = NSScreen.screens.first(where: { NSMouseInRect(mouseLocation, $0.frame, false) })
        return screenWithMouse
    }

    // 获取当前鼠标所在屏幕的截图
    func getScreenImage() async -> Bool {
        logger.info("getScreenImage")

        do {
            let availableContent = try await SCShareableContent.current

            guard let display = availableContent.displays.first else {
                logger.error("noDisplayFound")
                return false
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
                return false
            }

            let image = try await SCScreenshotManager.captureImage(
                contentFilter: contentFilter,
                configuration: configuration
            )
            screenImage = image
            return true
        } catch {
            logger.error("captureFailed: \(error.localizedDescription)")
            return false
        }
    }

    func saveImage() {
        guard cropRect != .zero else {
            logger.warning("cropRect is zero")
            return
        }
        guard let screenImage = screenImage else {
            logger.warning("screenImage is nil")
            return
        }

        logger.info("screenImage size: \(screenImage.height) x \(screenImage.width)")

        // 修正 y 轴坐标计算，确保截取区域与选择区域一致
        let clipRect = CGRect(x: cropRect.minX,
                              y: cropRect.minY,
                              width: cropRect.width,
                              height: cropRect.height)

        guard let croppedImage = screenImage.cropping(to: clipRect) else {
            logger.error("Failed to crop image")
            return
        }

        guard let effectImage = processImageWithEffects(inputImage: croppedImage) else {
            logger.error("Failed to apply effects to image")
            return
        }

        resultImage = effectImage

        let bitmap = NSBitmapImageRep(cgImage: effectImage)
        let pngData = bitmap.representation(using: .png, properties: [:])

        if let data = pngData {
            if imageSaveTo == .file {
                // totdo
                saveImageDataToFile(data)
            } else {
                saveImageDataToPasteboard(data)
            }
            setIsShow(false)
        }
    }

    func saveImageDataToPasteboard(_ data: Data) {
        let pb = NSPasteboard.general
        pb.clearContents()

        let saveRes = pb.setData(data, forType: .png)
        logger.info("save data in pasteboard is \(saveRes)")
        annotations.removeAll()
        annotationType = .none
    }

    func saveImageDataToFile(_ data: Data) {
        let url = Util.getImageSavePath()
        logger.info("Saving image to: \(url.path)")
        do {
            try data.write(to: url)
            logger.info("Image saved successfully at: \(url.path)")
        } catch {
            logger.error("Error saving image: \(error.localizedDescription)")
        }
        logger.info("save data in file is \(url.path)")
        annotations.removeAll()
        annotationType = .none
    }

    func savePinImage() {
        guard let resultImage = resultImage else {
            logger.info("resultImage is not nil")
            return
        }
        let bitmap = NSBitmapImageRep(cgImage: resultImage)
        let pngData = bitmap.representation(using: .png, properties: [:])

        if let data = pngData {
            saveImageDataToFile(data)
            logger.info("save data in file ")
        }
    }

    func saveImageAll() {
        guard cropRect != .zero else {
            logger.warning("cropRect is zero")
            return
        }
        guard let screenImage = screenImage else {
            logger.warning("screenImage is nil")
            return
        }

        logger.info("screenImage size: \(screenImage.width) x \(screenImage.height)")
        // 修正 y 轴坐标计算，确保截取区域与选择区域一致
        let clipRect = CGRect(x: cropRect.minX,
                              y: cropRect.minY,
                              width: cropRect.width,
                              height: cropRect.height)
        logger.info("clipRect size: \(clipRect.width) x \(clipRect.height)")

        guard let croppedImage = screenImage.cropping(to: clipRect) else {
            logger.error("Failed to crop image")
            return
        }

        // 合并 screenImage 和 annotationImage
        let combinedImage: CGImage
        if let annotationImage = annotationImage {
            logger.info("annotationImage size: \(annotationImage.width) x \(annotationImage.height)")
            combinedImage = mergeImages(baseImage: croppedImage, overlayImage: annotationImage)
        } else {
            logger.warning("no annotationImage")
            combinedImage = croppedImage
        }

        guard let effectImage = processImageWithEffects(inputImage: combinedImage) else {
            logger.error("Failed to apply effects to image")
            return
        }
        resultImage = effectImage
        let bitmap = NSBitmapImageRep(cgImage: effectImage)
        let pngData = bitmap.representation(using: .png, properties: [:])

        if let data = pngData {
            if imageSaveTo == .file {
                // totdo
                saveImageDataToFile(data)
            } else if imageSaveTo == .pasteboard {
                saveImageDataToPasteboard(data)
            } else if imageSaveTo == .pin {
                showPin = true
            }
            setIsShow(false)
        }
    }

    private func mergeImages(baseImage: CGImage, overlayImage: CGImage) -> CGImage {
        let width = max(baseImage.width, overlayImage.width)
        let height = max(baseImage.height, overlayImage.height)

        guard let context = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: baseImage.bitsPerComponent,
            bytesPerRow: 0,
            space: baseImage.colorSpace ?? CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: baseImage.bitmapInfo.rawValue
        ) else {
            logger.error("Failed to create CGContext for merging images")
            return baseImage
        }

        // 绘制底层图像
        context.draw(baseImage, in: CGRect(x: 0, y: 0, width: baseImage.width, height: baseImage.height))

        // 绘制叠加图像
        context.draw(overlayImage, in: CGRect(x: 0, y: 0, width: overlayImage.width, height: overlayImage.height))

        return context.makeImage() ?? baseImage
    }

    func processImageWithEffects(
        inputImage: CGImage,
        cornerRadius: CGFloat = 8.0,
        shadowOffset: CGSize = CGSize(width: 0, height: 0),
        shadowBlur: CGFloat = 20,
        shadowColor: CGColor = NSColor.black.withAlphaComponent(0.6).cgColor
    ) -> CGImage? {
        let width = inputImage.width
        let height = inputImage.height

        // 为阴影预留空间
        let contextWidth = width + Int(shadowBlur * 2)
        let contextHeight = height + Int(shadowBlur * 2)

        let colorSpace = CGColorSpaceCreateDeviceRGB()

        guard let context = CGContext(
            data: nil,
            width: contextWidth,
            height: contextHeight,
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else {
            return nil
        }

        context.interpolationQuality = .high
        context.setAllowsAntialiasing(true)
        context.setShouldAntialias(true)

        // 图片绘制区域（居中）
         let imageRect = CGRect(
             x: shadowBlur,
             y: shadowBlur,
             width: CGFloat(width),
             height: CGFloat(height)
         )
         
         // 1. 先绘制阴影
         context.saveGState()
         let shadowPath = CGPath(roundedRect: imageRect,
                                cornerWidth: cornerRadius,
                                cornerHeight: cornerRadius,
                                transform: nil)
         context.addPath(shadowPath)
         context.setShadow(offset: shadowOffset,
                          blur: shadowBlur,
                          color: shadowColor)
         context.fillPath()
         context.restoreGState()
         
         // 2. 再绘制带圆角的图片
         context.saveGState()
         let clipPath = CGPath(roundedRect: imageRect,
                              cornerWidth: cornerRadius,
                              cornerHeight: cornerRadius,
                              transform: nil)
         context.addPath(clipPath)
         context.clip()
         context.draw(inputImage, in: imageRect)
         context.restoreGState()

        // 生成新 CGImage
        return context.makeImage()
    }
    func setIsShow(_ isShow: Bool) {
        logger.info("start show overlayer")
        self.isShow = isShow
    }

    func hideOverlayerWin() {
        print("start hide overlayer")
        isShow = false
        if let window = NSApplication.shared.windows.first(where: { $0.title == "Item-0" }) {
            window.close()
        } else {
            print("hide overlayer failed - window not found")
        }
    }

    func resetState() {
        isShow = false
        cropRect = .zero
        annotationType = .none
        annotations = []
        screenImage = nil
        annotationImage = nil
    }
}
