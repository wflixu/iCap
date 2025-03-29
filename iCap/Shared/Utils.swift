//
//  Utils.swift
//  iCap
//
//  Created by 李旭 on 2025/3/29.
//

import Foundation
import AppKit

class Util {
    static func getDatetimeFileName(_ type: NSBitmapImageRep.FileType = .png) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HH:mm:ss"

        let now = Date()
        let timestampAndDateString = formatter.string(from: now)

        return timestampAndDateString + type.desc
    }

    static func getHomePath() -> String {
        return "/" + (URL.homeDirectory.path as NSString).pathComponents[1...2].joined(separator: "/")
    }
    static func getDesktopPath() -> String {
        return Util.getHomePath() + "/Desktop/"
    }
}
