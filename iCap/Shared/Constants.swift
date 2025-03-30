//
//  Constants.swift
//  iCap
//
//  Created by 李旭 on 2024/4/26.
//

import Foundation

import AppKit
import KeyboardShortcuts


enum Keys {
    static let savePathBookmarkStorage = "SAVE_PATH_BOOKMARK_STORAGE"
    static let imageFormat = "IMAGE_FORMAT"
    static let imageSavePath = "IMAGE_SAVE_PATH"
}

enum ImageFormat: String { case png, jpeg }


enum AppError: Error {
    case notDisplay
    case permissionDenied
    case noDisplayFound
    case captureFailed(String)
}



enum DrawingTool: String {
    case rectangle
    case arrow
    case text
    case freehand
}

enum LineWidth: CGFloat {
    case thin = 1.0
    case medium = 3.0
    case thick = 5.0
}

enum ColorPreset {
    static let red = NSColor(red: 1, green: 0, blue: 0, alpha: 1)
    static let green = NSColor(red: 0, green: 1, blue: 0, alpha: 1)
    static let blue = NSColor(red: 0, green: 0, blue: 1, alpha: 1)
    static let black = NSColor(red: 0, green: 0, blue: 0, alpha: 1)
    static let white = NSColor(red: 1, green: 1, blue: 1, alpha: 1)
}

extension NSBitmapImageRep.FileType {
    var desc: String {
        switch self {
            case .png:
                ".png"
            case .jpeg:
                ".jpeg"
            default:
                ""
        }
    }
}

enum ImageSaveTo: String {
    case file, pasteboard
}

enum WindowTitle: String {
    case overlay, actionbar, overlayer

    var desc: String {
        switch self {
            case .overlay:
                "Area Selector"
            case .overlayer:
                "Overlayer"
            case .actionbar:
                "Action Bar"
        }
    }
}

enum AppWinsInfo: String {
    case overlayer, main

    var desc: String {
        switch self {
            case .overlayer:
                "Overlayer"
            case .main:
                "iCap"
        }
    }

    var id: String {
        switch self {
            case .overlayer:
                "overlayer"
            case .main:
                "main"
        }
    }
}



