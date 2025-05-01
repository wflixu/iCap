//
//  Constants.swift
//  iCap
//
//  Created by 李旭 on 2024/4/26.
//

import AppKit
import Foundation
import KeyboardShortcuts

enum Keys {
    static let savePathBookmarkStorage = "SAVE_PATH_BOOKMARK_STORAGE"
    static let imageFormat = "IMAGE_FORMAT"
    // 保存路径
    static let imageSaveDir = "IMAGE_SAVE_DIR"
    static let imageSavePath = "IMAGE_SAVE_PATH"
    static let coordinate = "OVERLAYER"
}

enum ImageFormat: String {
    case png, jpeg
   var ext: String {
        return "." + self.rawValue
    }

    static func fromUserDefaults() -> ImageFormat? {
        guard let raw = UserDefaults.group.string(forKey: Keys.imageFormat) else {
            logger.warning("未找到图片格式设置，使用默认格式（png）")
            return .png
        }

        if let format = ImageFormat(rawValue: raw.lowercased()) {
            return format
        } else {
            logger.warning("无效的图片格式设置: \(raw)，使用默认格式（png）")
            return .png
        }
    }
}

extension NSBitmapImageRep.FileType {
    var desc: String {
        switch self {
            case .png: ".png"
            case .jpeg: ".jpeg"
            default: ""
        }
    }
}

enum ImageSaveTo: String {
    case file, pasteboard, all
}

enum AppWinsInfo: String {
    case overlayer, main, editor

    var desc: String {
        switch self {
            case .overlayer: "Overlayer"
            case .main: "iCap"
            case .editor: "Editor"
        }
    }

    var id: String {
        switch self {
            case .overlayer: "overlayer"
            case .main: "main"
            case .editor: "editor"
        }
    }
}
