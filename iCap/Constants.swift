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
