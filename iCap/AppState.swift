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
        cornerRadius: CGFloat = 10,
        shadowColor: NSColor = .black,
        shadowOffset: CGSize = .init(width: 0, height: 0),
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
