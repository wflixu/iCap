//
//  Utils.swift
//  iCap
//
//  Created by 李旭 on 2025/3/29.
//

import AppKit
import Foundation

class Util {
    static func getDatetimeFileName() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HH:mm:ss"

        let now = Date()
        // 获取时间戳字符串
        let timestampAndDateString = formatter.string(from: now)
        let format = ImageFormat.fromUserDefaults() ?? .png

        logger.debug("使用图片格式: \(format.rawValue)")
        return timestampAndDateString + format.ext
    }

    static func getHomePath() -> String {
        return "/" + (URL.homeDirectory.path as NSString).pathComponents[1 ... 2].joined(separator: "/")
    }

    static func getDesktopPath() -> String {
        return Util.getHomePath() + "/Desktop/"
    }

    static func getImageSavePath() -> URL {
        // 读取 UserDefaults 中存储的路径
        let saveDir = UserDefaults.group.string(forKey: Keys.imageSaveDir) ?? "/Users/"
        return URL(fileURLWithPath: saveDir).appendingPathComponent(Util.getDatetimeFileName())
    }

    static func saveBookmark(for url: URL, key: String) {
        do {
            // 生成安全作用域书签（含持久化权限）
            let bookmarkData = try url.bookmarkData(
                options: .withSecurityScope,
                includingResourceValuesForKeys: nil,
                relativeTo: nil
            )

            // 存储到 UserDefaults（或本地数据库）
            UserDefaults.group.set(bookmarkData, forKey: key)
        } catch {
            print("保存书签失败: \(error)")
        }
    }

    static func restoreFolderAccess(key: String) -> URL? {
        guard let bookmarkData = UserDefaults.group.data(forKey: key) else {
            return nil
        }

        do {
            var isStale = false
            let url = try URL(
                resolvingBookmarkData: bookmarkData,
                options: .withSecurityScope,
                relativeTo: nil,
                bookmarkDataIsStale: &isStale
            )

            if isStale {
                // 书签过期需重新生成（如文件夹移动）
                Util.saveBookmark(for: url, key: key)
            }

            // 激活安全作用域权限
            if url.startAccessingSecurityScopedResource() {
                return url
            }
        } catch {
            print("恢复书签失败: \(error)")
        }

        return nil
    }

    static func showOrCreateWindow(windowId: String, callback: () -> Void) {
        if let window = NSApp.windows.first(where: {
            guard let rawValue = $0.identifier?.rawValue else { return false }
            return rawValue == windowId
        }) {
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
        } else {
            callback()
        }
    }

    static func setOverlayWindowLevel(_ level: NSWindow.Level) {
        for w in NSApplication.shared.windows.filter({ $0.title == AppWinsInfo.overlayer.desc }) {
            w.level = level
        }
    }
}
