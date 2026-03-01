//
//  AnnotationView.swift
//  iCap
//
//  Created by 李旭 on 2025/4/20.
//

import AppKit
import Foundation
import CoreGraphics
import SwiftUI
import UniformTypeIdentifiers

struct ActiveAnnotationView: View {
    @State var sartPoint: CGPoint = .zero
    @State var offset: CGSize = .zero
    @State var changeSize: CGSize = .zero

    var annotation: Annotation
    var onUpdateFrame: (CGSize, CGSize) -> Void

    // 计算矩形 8 个控制点的位置
    var controlPoints: [CPoint] {
        return [.topLeft, .top, .topRight, .left, .right, .bottomLeft, .bottom, .bottomRight]
    }

    var livingSize: CGSize {
        let originSize = annotation.frame.size
        return CGSize(width: originSize.width + changeSize.width, height: originSize.height + changeSize.height)
    }

    var body: some View {
        Group {
            if annotation.type == .rect {
                Rectangle()
                    .stroke(
                        annotation.color.opacity(0.8),
                        style: StrokeStyle(
                            lineWidth: annotation.lineWidth,
                            dash: annotation.dashPattern ?? []
                        )
                    )
                    .fill(annotation.isFilled ? annotation.color.opacity(0.2) : Color.clear)
                    .offset(offset)
                    .highPriorityGesture(
                        DragGesture(minimumDistance: 5.0, coordinateSpace: .named(Keys.coordinate))
                            .onChanged { event in
                                // 记录拖动起始位置
                                if sartPoint == .zero {
                                    sartPoint = event.startLocation
                                }
                                // 计算偏移量
                                offset = event.translation

                                print("拖动中 - 坐标: (\(event.location.x), \(event.location.y)) , 偏移: \(event.translation.width), \(event.translation.height)")
                            }
                            .onEnded { _ in
                                // 重置起始位置和偏移
                                movingAnnotation(offset)
                                sartPoint = .zero
                                offset = .zero
                            }
                    )
                    .frame(width: livingSize.width, height: livingSize.height)
                    //  绘制 8 个控制点圆环
                    .overlay(
                        ForEach(controlPoints, id: \.self) { cpoint in
                            Circle()
                                .fill(Color.blue)
                                .frame(width: 12, height: 12)
                                .onHover(perform: { hovering in
                                    if hovering {
                                        setCursorbyIndex(cpoint)
                                    } else {
                                        NSCursor.pop()
                                    }
                                }
                                )
                                .position(cpoint.position(self.livingSize))
                                .offset(offset)
                                .gesture(
                                    DragGesture(minimumDistance: 3, coordinateSpace: .named(Keys.coordinate))
                                        .onChanged { event in
                                            print("拖动中 - 坐标: (\(event.location.x), \(event.location.y)) , 偏移: \(event.translation.width), \(event.translation.height) 起点：\(event.startLocation.x), \(event.startLocation.y)")

                                            // 计算新的宽高
                                            changeSize = cpoint.getTargetChangedSize(event.translation)
                                            offset = cpoint.getViewOffset(event.translation)
                                        }
                                        .onEnded { event in
                                            let size: CGSize = cpoint.getTargetChangedSize(event.translation)
                                            let trans: CGSize = cpoint.getOriginTrans(event.translation)
                                            // 计算新的宽高
                                            onUpdateFrame(trans, size)
                                            changeSize = .zero
                                            offset = .zero
                                        }
                                )
                        }
                    )
            } else if annotation.type == .arrow {
                Path { path in
                    let start = CGPoint(
                        x: offset.width > 0 ? 0 : -offset.width,
                        y: offset.height > 0 ? 0 : -offset.height
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
                .fill(annotation.arrowStyle == .filled ? annotation.color.opacity(0.8) : Color.clear)
                .stroke(
                    annotation.color.opacity(0.8),
                    style: StrokeStyle(
                        lineWidth: annotation.lineWidth,
                        lineCap: .round,
                        lineJoin: .round
                    )
                )
                .frame(width: livingSize.width, height: livingSize.height)
                .offset(offset)
                .highPriorityGesture(
                    DragGesture(minimumDistance: 5.0, coordinateSpace: .named(Keys.coordinate))
                        .onChanged { event in
                            // 记录拖动起始位置
                            if sartPoint == .zero {
                                sartPoint = event.startLocation
                            }
                            // 计算偏移量
                            offset = event.translation

                            print("拖动中 - 坐标: (\(event.location.x), \(event.location.y)) , 偏移: \(event.translation.width), \(event.translation.height)")
                        }
                        .onEnded { _ in
                            // 重置起始位置和偏移
                            movingAnnotation(offset)
                            sartPoint = .zero
                            offset = .zero
                        }
                )
            } else if annotation.type == .text {
                // For text annotations, just show the text with a selection border
                Text(annotation.text.isEmpty ? "Text" : annotation.text)
                    .font(.system(size: annotation.fontSize))
                    .foregroundColor(annotation.color.opacity(0.8))
                    .frame(width: livingSize.width, height: livingSize.height, alignment: .topLeading)
                    .offset(offset)
                    .highPriorityGesture(
                        DragGesture(minimumDistance: 5.0, coordinateSpace: .named(Keys.coordinate))
                            .onChanged { event in
                                // 记录拖动起始位置
                                if sartPoint == .zero {
                                    sartPoint = event.startLocation
                                }
                                // 计算偏移量
                                offset = event.translation

                                print("拖动中 - 坐标: (\(event.location.x), \(event.location.y)) , 偏移: \(event.translation.width), \(event.translation.height)")
                            }
                            .onEnded { _ in
                                // 重置起始位置和偏移
                                movingAnnotation(offset)
                                sartPoint = .zero
                                offset = .zero
                            }
                    )
            } else if annotation.type == .number {
                // 序号标注 - 可拖动位置
                ZStack {
                    Circle()
                        .fill(annotation.color.opacity(0.8))
                    Text("\(annotation.number)")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                }
                .frame(width: 30, height: 30)
                .offset(offset)
                .highPriorityGesture(
                    DragGesture(minimumDistance: 5.0, coordinateSpace: .named(Keys.coordinate))
                        .onChanged { event in
                            if sartPoint == .zero {
                                sartPoint = event.startLocation
                            }
                            offset = event.translation
                        }
                        .onEnded { _ in
                            movingAnnotation(offset)
                            sartPoint = .zero
                            offset = .zero
                        }
                )
            } else if annotation.type == .blur {
                // 马赛克 - 可拖动和调整大小
                ZStack {
                    Rectangle()
                        .fill(Color.white.opacity(0.3))
                        .blur(radius: min(annotation.blurRadius, 10))
                    Rectangle()
                        .stroke(Color.gray.opacity(0.5), style: StrokeStyle(lineWidth: 1, dash: [5, 5]))
                }
                .frame(width: livingSize.width, height: livingSize.height)
                .offset(offset)
                .highPriorityGesture(
                    DragGesture(minimumDistance: 5.0, coordinateSpace: .named(Keys.coordinate))
                        .onChanged { event in
                            if sartPoint == .zero {
                                sartPoint = event.startLocation
                            }
                            offset = event.translation
                        }
                        .onEnded { _ in
                            movingAnnotation(offset)
                            sartPoint = .zero
                            offset = .zero
                        }
                )
                // 添加调整大小的控制点
                .overlay(
                    ForEach(controlPoints, id: \.self) { cpoint in
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 12, height: 12)
                            .onHover(perform: { hovering in
                                if hovering {
                                    setCursorbyIndex(cpoint)
                                } else {
                                    NSCursor.pop()
                                }
                            })
                            .position(cpoint.position(self.livingSize))
                            .offset(offset)
                            .gesture(
                                DragGesture(minimumDistance: 3, coordinateSpace: .named(Keys.coordinate))
                                    .onChanged { event in
                                        changeSize = cpoint.getTargetChangedSize(event.translation)
                                        offset = cpoint.getViewOffset(event.translation)
                                    }
                                    .onEnded { event in
                                        let size: CGSize = cpoint.getTargetChangedSize(event.translation)
                                        let trans: CGSize = cpoint.getOriginTrans(event.translation)
                                        onUpdateFrame(trans, size)
                                        changeSize = .zero
                                        offset = .zero
                                    }
                            )
                    }
                )
            } else if annotation.type == .highlight {
                // 高亮标记 - 可拖动和调整大小
                Rectangle()
                    .fill(annotation.color.opacity(0.3))
                    .frame(width: livingSize.width, height: livingSize.height)
                    .offset(offset)
                    .blendMode(.multiply)
                    .highPriorityGesture(
                        DragGesture(minimumDistance: 5.0, coordinateSpace: .named(Keys.coordinate))
                            .onChanged { event in
                                if sartPoint == .zero {
                                    sartPoint = event.startLocation
                                }
                                offset = event.translation
                            }
                            .onEnded { _ in
                                movingAnnotation(offset)
                                sartPoint = .zero
                                offset = .zero
                            }
                    )
                    // 添加调整大小的控制点
                    .overlay(
                        ForEach(controlPoints, id: \.self) { cpoint in
                            Circle()
                                .fill(Color.blue)
                                .frame(width: 12, height: 12)
                                .onHover(perform: { hovering in
                                    if hovering {
                                        setCursorbyIndex(cpoint)
                                    } else {
                                        NSCursor.pop()
                                    }
                                })
                                .position(cpoint.position(self.livingSize))
                                .offset(offset)
                                .gesture(
                                    DragGesture(minimumDistance: 3, coordinateSpace: .named(Keys.coordinate))
                                        .onChanged { event in
                                            changeSize = cpoint.getTargetChangedSize(event.translation)
                                            offset = cpoint.getViewOffset(event.translation)
                                        }
                                        .onEnded { event in
                                            let size: CGSize = cpoint.getTargetChangedSize(event.translation)
                                            let trans: CGSize = cpoint.getOriginTrans(event.translation)
                                            onUpdateFrame(trans, size)
                                            changeSize = .zero
                                            offset = .zero
                                        }
                                )
                        }
                    )
            }
        }
        .opacity(annotation.opacity)
        .border(annotation.isSelected ? Color.blue : Color.clear, width: annotation.isSelected ? 2 : 0)
    }

    func getArrowStartPoint(_ offset: CGSize) -> CGPoint {
        return CGPoint(
            x: offset.width > 0 ? 0 : -offset.width,
            y: offset.height > 0 ? 0 : -offset.height
        )
    }

    func movingAnnotation(_ offset: CGSize) {
        // 通过回调通知父视图更新frame
        print("movingAnnotation ......")
        onUpdateFrame(offset, .zero)
    }

    func resizeAnnotationFrame(_ size: CGSize) {
        onUpdateFrame(.zero, size)
    }

    func setCursorbyIndex(_ cp: CPoint) {
        NSCursor.frameResize(position: cp.frameResizePosition, directions: .all).push()
    }
}
