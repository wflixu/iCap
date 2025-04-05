//
//  CrosshairView.swift
//  iCap
//
//  Created by 李旭 on 2024/4/15.
//
import Foundation
import SwiftUI


//
//struct CrosshairView: View {
//    @Binding var selectionRect: NSRect?
//
//    var body: some View {
//        GeometryReader { geometry in
//            let rect = selectionRect ?? geometry.frame
//            ZStack {
//                Rectangle()
//                    .fill(Color.clear)
//                    .border(Color.red, width: 2)
//                    .frame(width: rect.width, height: rect.height)
//
//                Rectangle()
//                    .fill(Color.clear)
//                    .border(Color.red, width: 2)
//                    .frame(width: 2, height: rect.height)
//                    .position(x: rect.midX, y: rect.minY)
//
//                Rectangle()
//                    .fill(Color.clear)
//                    .border(Color.red, width: 2)
//                    .frame(width: rect.width, height: 2)
//                    .position(x: rect.minX, y: rect.midY)
//            }
//            .onMouseDown { event in
//                selectionRect = NSRect(origin: event.locationInWindow, size: .zero)
//            }
//            .onMouseDrag { event in
//                guard var rect = selectionRect else { return }
//                rect.size = CGSize(width: event.locationInWindow.x - rect.origin.x,
//                                   height: event.locationInWindow.y - rect.origin.y)
//                selectionRect = rect
//            }
//            .onMouseUp { _ in
//                selectionRect = nil
//            }
//        }
//    }
//}
//
//#Preview {
//    CrosshairView()
//}
