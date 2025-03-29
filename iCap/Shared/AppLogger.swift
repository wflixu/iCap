//
//  AppLogger.swift
//  iCap
//
//  Created by 李旭 on 2025/3/29.
//

import Foundation
import OSLog


@propertyWrapper
struct AppLog {

    private let logger: Logger

    init(subsystem: String = Bundle.main.bundleIdentifier ?? "", category: String = "main") {
        self.logger = Logger(subsystem: subsystem, category: category)
    }

    var wrappedValue: Logger {
        return logger
    }
}


