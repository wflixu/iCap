//
//  AnnotationView.swift
//  iCap
//
//  Created by 李旭 on 2025/4/26.
//

import SwiftUI

struct AnnotationView: View {
    var annotation: Annotation

    var body: some View {
        if annotation.type == .rect {
            Rectangle()
                .stroke(Color.red, lineWidth: 2)
                .fill(Color.blue.opacity(0.01))
                .frame(width: annotation.frame.width, height: annotation.frame.height)
            //  绘制 8 个控制点圆环
        }

        if annotation.type == .arrow {
            Path { path in
                let start = CGPoint(
                    x: annotation.offset.width > 0 ? 0 : -annotation.offset.width,
                    y: annotation.offset.height > 0 ? 0 : -annotation.offset.height
                )
                let end = CGPoint(x: start.x + annotation.offset.width, y: start.y + annotation.offset.height)
                path.move(to: start)
                path.addLine(to: end)

                // 绘制箭头头部
                let angle = atan2(end.y - start.y, end.x - start.x)
                let arrowLength: CGFloat = 10

                path.move(to: end)
                path.addLine(to: CGPoint(
                    x: end.x - arrowLength * cos(angle - .pi/6),
                    y: end.y - arrowLength * sin(angle - .pi/6)
                ))

                path.addLine(to: CGPoint(
                    x: end.x - arrowLength * cos(angle + .pi/6),
                    y: end.y - arrowLength * sin(angle + .pi/6)
                ))

                path.closeSubpath()
            }
            .stroke(Color.red, lineWidth: 2)
            .frame(width: annotation.frame.width, height: annotation.frame.height)
        }
    }

    func getArrowStartPoint(_ offset: CGSize) -> CGPoint {
        return CGPoint(
            x: offset.width > 0 ? 0 : -offset.width,
            y: offset.height > 0 ? 0 : -offset.height
        )
    }

    func setCursorbyIndex(_ cp: CPoint) {
        NSCursor.frameResize(position: cp.frameResizePosition, directions: .all).push()
    }
}
