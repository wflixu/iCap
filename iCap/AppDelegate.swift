//
//  AppDelegate.swift
//  iCap
//
//  Created by 李旭 on 2024/4/15.
//

import AppKit
import Cocoa
import Foundation

import os.log

private let logger = Logger()

class AppDelegate: NSObject, NSApplicationDelegate {
    var eventMonitor: Any?
    func applicationDidFinishLaunching(_ notification: Notification) {
        logger.warning("applicationDidFinishLaunching")

        // 创建事件监听器
        NSEvent.addGlobalMonitorForEvents(matching: NSEvent.EventTypeMask.keyDown) { event in
            logger.warning("addGlobalMonitorForEvents\(event.keyCode)")
            if event.modifierFlags.contains(.command), event.modifierFlags.contains(.shift), event.charactersIgnoringModifiers == "x" {
                // 在这里处理快捷键逻辑
                // 例如，唤醒应用窗口或执行其他操作
                print("Command + Shift + X pressed")
            } else {
                logger.warning("no target")
            }
        }
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
}
