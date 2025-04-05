//
//  Extensions.swift
//  iCap
//
//  Created by 李旭 on 2025/3/30.
//

import Foundation
import OSLog

import AppKit
import KeyboardShortcuts


extension KeyboardShortcuts.Name {
    static let startScreenShot = Self("startScreenShot")
}

extension UserDefaults {
    static var group: UserDefaults {
        UserDefaults(suiteName: "4L3563XCBN.cn.wflixu.icap")!
    }

    private func defaults<T>(for key: String) -> T? {
        if let value = object(forKey: key) as? T {
            return value
        } else {
            logger.warning("Missing key for \(key, privacy: .public), using default true value")
            return nil
        }
    }
}
