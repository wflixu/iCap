//
//  Constants.swift
//  iCap
//
//  Created by 李旭 on 2024/4/26.
//

import Foundation

import AppKit
import KeyboardShortcuts

extension KeyboardShortcuts.Name {
    static let startScreenShot = Self("startScreenShot")
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

struct ColorPreset {
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

enum ImageSaveTo:String {
    case file, pasteboard
}

enum WindowTitle:String {
    case overlay, actionbar
    
    var desc: String {
        switch self {
            case .overlay:
                "Area Selector"
            case .actionbar:
                "Action Bar"
                
        }
    }
}

enum ImageFormat: String { case png, jpeg }


class Util {
    static func getDatetimeFileName(_ type: NSBitmapImageRep.FileType = .png) -> String {
 
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HH:mm:ss"

        let now = Date()
        let timestampAndDateString = formatter.string(from: now)

       
        return  timestampAndDateString + type.desc
    }
}
