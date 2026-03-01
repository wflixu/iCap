//
//  AnnotationView.swift
//  iCap
//
//  Created by 李旭 on 2025/4/26.
//

import AppKit
import Foundation
import SwiftUI
import UniformTypeIdentifiers

struct AnnotationView: View {
    var annotation: Annotation

    var body: some View {
        Group {
            if annotation.type == .rect {
                Rectangle()
                    .stroke(
                        annotation.color,
                        style: StrokeStyle(
                            lineWidth: annotation.lineWidth,
                            dash: annotation.dashPattern ?? []
                        )
                    )
                    .fill(annotation.isFilled ? annotation.color.opacity(0.2) : Color.clear)
                    .frame(width: annotation.frame.width, height: annotation.frame.height)
                    .opacity(annotation.opacity)
                    .border(annotation.isSelected ? Color.blue : Color.clear, width: annotation.isSelected ? 2 : 0)
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
                    let arrowLength = annotation.arrowHeadSize

                    if annotation.arrowStyle == .filled {
                        // 实心箭头
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
                    } else {
                        // 标准空心箭头
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
                }
                .fill(annotation.arrowStyle == .filled ? annotation.color : Color.clear)
                .stroke(
                    annotation.color,
                    style: StrokeStyle(
                        lineWidth: annotation.lineWidth,
                        lineCap: .round,
                        lineJoin: .round
                    )
                )
                .opacity(annotation.opacity)
                .frame(width: annotation.frame.width, height: annotation.frame.height)
                .border(annotation.isSelected ? Color.blue : Color.clear, width: annotation.isSelected ? 2 : 0)
            }

            if annotation.type == .text {
                Text(annotation.text)
                    .font(.system(size: annotation.fontSize))
                    .foregroundColor(annotation.color)
                    .opacity(annotation.opacity)
                    .frame(width: annotation.frame.width, height: annotation.frame.height, alignment: .topLeading)
                    .border(annotation.isSelected ? Color.blue : Color.clear, width: annotation.isSelected ? 2 : 0)
            }

            // 序号标注
            if annotation.type == .number {
                ZStack {
                    Circle()
                        .fill(annotation.color)
                    Text("\(annotation.number)")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                }
                .frame(width: 30, height: 30)
                .opacity(annotation.opacity)
                .border(annotation.isSelected ? Color.blue : Color.clear, width: annotation.isSelected ? 2 : 0)
            }

            // 马赛克/模糊
            if annotation.type == .blur {
                ZStack {
                    // 模糊效果预览
                    Rectangle()
                        .fill(Color.white.opacity(0.3))
                        .blur(radius: min(annotation.blurRadius, 10))
                    // 虚线边框指示模糊区域
                    Rectangle()
                        .stroke(Color.gray.opacity(0.5), style: StrokeStyle(lineWidth: 1, dash: [5, 5]))
                }
                .frame(width: annotation.frame.width, height: annotation.frame.height)
                .opacity(annotation.opacity)
                .border(annotation.isSelected ? Color.blue : Color.clear, width: annotation.isSelected ? 2 : 0)
            }

            // 高亮标记
            if annotation.type == .highlight {
                Rectangle()
                    .fill(annotation.color.opacity(0.3))
                    .frame(width: annotation.frame.width, height: annotation.frame.height)
                    .blendMode(.multiply)
                    .opacity(annotation.opacity)
                    .border(annotation.isSelected ? Color.blue : Color.clear, width: annotation.isSelected ? 2 : 0)
            }
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
