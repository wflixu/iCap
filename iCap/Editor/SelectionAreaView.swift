//
//  CrosshairView.swift
//  iCap
//
//  Created by 李旭 on 2024/4/15.
//
import Foundation
import SwiftUI

struct SelectionAreaView: View {
    @EnvironmentObject var appState: AppState

    @State var sartPoint: CGPoint = .zero
    @State var offset: CGSize = .zero
    @State var changeSize: CGSize = .zero

    // 用于存储所有可拖动形状的数据
    @State private var annotations: [Annotation] = []

 

    let editable: Bool

    var frame: CGRect
    var onUpdateFrame: (CGSize, CGSize) -> Void

    // 计算矩形 8 个控制点的位置
    var controlPoints: [CPoint] {
        return [.topLeft, .top, .topRight, .left, .right, .bottomLeft, .bottom, .bottomRight]
    }

    var livingSize: CGSize {
        let originSize = frame.size
        return CGSize(width: originSize.width + changeSize.width, height: originSize.height + changeSize.height)
    }

    var annotationType: AnnotationType {
        appState.annotationType
    }

    var body: some View {
        Rectangle()
            .stroke(Color.black, lineWidth: 6)
            .fill(Color.black.opacity(0.01))
            .offset(offset)
            .highPriorityGesture(
                DragGesture(minimumDistance: 5.0, coordinateSpace: .named(Keys.coordinate))
                    .onChanged { event in

                        guard editable else {
                            return
                        }
                        // 记录拖动起始位置
                        if sartPoint == .zero {
                            sartPoint = event.startLocation
                        }
                        // 计算偏移量
                        offset = event.translation

                        logger.info("拖动中 - 坐标: (\(event.location.x), \(event.location.y)) , 偏移: \(event.translation.width), \(event.translation.height)")
                    }
                    .onEnded { _ in
                        guard editable else {
                            return
                        }

                        // 重置起始位置和偏移
                        movingAnnotation(offset)
                        sartPoint = .zero
                        offset = .zero
                    }
            )
            .frame(width: livingSize.width, height: livingSize.height)
            // 绘制 8 个控制点圆环，仅在可编辑状态下显示
            .overlay(
                Group {
                    if editable {
                        ForEach(controlPoints, id: \.self) { cpoint in

                            Circle()
                                .fill(Color.blue)
                                .frame(width: 12, height: 12)
                                .onHover(perform: { hovering in
                                    guard editable else {
                                        return
                                    }
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

                                            logger.info("拖动中 - 坐标: (\(event.location.x), \(event.location.y)) , 偏移: \(event.translation.width), \(event.translation.height) 起点：\(event.startLocation.x), \(event.startLocation.y)")

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
                    }
                }
            )
            .overlay(
                Text("ann offset: \(offset.width), \(offset.height) ; size: \(changeSize.width), \(changeSize.height)")
            )
        if !editable {
           
        }
    }

    

    func getArrowStartPoint(_ offset: CGSize) -> CGPoint {
        return CGPoint(
            x: offset.width > 0 ? 0 : -offset.width,
            y: offset.height > 0 ? 0 : -offset.height
        )
    }

    func movingAnnotation(_ offset: CGSize) {
        // 通过回调通知父视图更新frame
        logger.warning("movingAnnotation ......")
        onUpdateFrame(offset, .zero)
    }

    func resizeAnnotationFrame(_ size: CGSize) {
        onUpdateFrame(.zero, size)
    }

    func setCursorbyIndex(_ cp: CPoint) {
        NSCursor.frameResize(position: cp.frameResizePosition, directions: .all).push()
    }

}
