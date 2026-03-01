//
//  ActionBarView.swift
//  iCap
//
//  Created by 李旭 on 2025/3/29.
//

import AppKit
import Foundation
import SwiftUI
import UniformTypeIdentifiers

struct ActionBarView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var annotationManager: AnnotationManager

    var body: some View {
        ZStack(alignment: Alignment(horizontal: .leading, vertical: .top)) {
            HStack(alignment: .center, spacing: 8) {
                // Undo/Redo buttons
                Button(action: {
                    annotationManager.undo()
                }) {
                    Image(systemName: "arrow.uturn.backward")
                        .font(.system(size: 20, weight: .medium))
                        .frame(width: 28, height: 28)
                        .foregroundColor(annotationManager.undoStack.isEmpty ? .gray : .blue)
                }
                .buttonStyle(PlainButtonStyle())
                .help("Undo")
                .disabled(annotationManager.undoStack.isEmpty)

                Button(action: {
                    annotationManager.redo()
                }) {
                    Image(systemName: "arrow.uturn.forward")
                        .font(.system(size: 20, weight: .medium))
                        .frame(width: 28, height: 28)
                        .foregroundColor(annotationManager.redoStack.isEmpty ? .gray : .blue)
                }
                .buttonStyle(PlainButtonStyle())
                .help("Redo")
                .disabled(annotationManager.redoStack.isEmpty)

                Spacer()

                Button(action: {
                    appState.toggleAnnotationType(.rect)
                }) {
                    Image(systemName: "rectangle")
                        .font(.system(size: 20, weight: .medium))
                        .frame(width: 28, height: 28)
                        .foregroundColor(appState.annotationType == .rect ? .accentColor : .gray)
                }.buttonStyle(PlainButtonStyle())
                    .help("矩形框")

                Button(action: {
                    appState.toggleAnnotationType(.arrow)
                }) {
                    Image(systemName: "arrow.right")
                        .font(.system(size: 20, weight: .medium))
                        .frame(width: 28, height: 28)
                        .foregroundColor(appState.annotationType == .arrow ? .accentColor : .gray)
                }.buttonStyle(PlainButtonStyle())
                    .help("箭头")

                Button(action: {
                    appState.annotationType = .text
                    appState.savingDrawing = !appState.savingDrawing
                }) {
                    Image(systemName: "character")
                        .font(.system(size: 20, weight: .medium))
                        .frame(width: 28, height: 28)
                        .foregroundColor(appState.annotationType == .text ? .accentColor : .gray)
                }.buttonStyle(PlainButtonStyle())
                    .help("文字")

                // 序号标注按钮
                Button(action: {
                    appState.toggleAnnotationType(.number)
                }) {
                    Image(systemName: "list.number")
                        .font(.system(size: 20, weight: .medium))
                        .frame(width: 28, height: 28)
                        .foregroundColor(appState.annotationType == .number ? .accentColor : .gray)
                }.buttonStyle(PlainButtonStyle())
                    .help("序号")

                // 马赛克按钮
                Button(action: {
                    appState.toggleAnnotationType(.blur)
                }) {
                    Image(systemName: "eye.slash")
                        .font(.system(size: 20, weight: .medium))
                        .frame(width: 28, height: 28)
                        .foregroundColor(appState.annotationType == .blur ? .accentColor : .gray)
                }.buttonStyle(PlainButtonStyle())
                    .help("马赛克")

                // 高亮按钮
                Button(action: {
                    appState.toggleAnnotationType(.highlight)
                }) {
                    Image(systemName: "highlighter")
                        .font(.system(size: 20, weight: .medium))
                        .frame(width: 28, height: 28)
                        .foregroundColor(appState.annotationType == .highlight ? .accentColor : .gray)
                }.buttonStyle(PlainButtonStyle())
                    .help("高亮")

                // Delete selected annotation button
                Button(action: {
                    if let selectedId = annotationManager.selectedAnnotationId {
                        annotationManager.delete(selectedId)
                    }
                }) {
                    Image(systemName: "trash")
                        .font(.system(size: 20, weight: .medium))
                        .frame(width: 28, height: 28)
                        .foregroundColor(annotationManager.selectedAnnotationId != nil ? .red : .gray)
                }
                .buttonStyle(PlainButtonStyle())
                .help("Delete selected annotation")
                .disabled(annotationManager.selectedAnnotationId == nil)

                Button(action: {
                    self.onPinImage()
                }) {
                    Image(systemName: "pin.square")
                        .font(.system(size: 20, weight: .medium))
                        .frame(width: 28, height: 28)
                        .foregroundColor(.gray)
                }.buttonStyle(PlainButtonStyle())
                    .help("固定")

                Button(action: {
                    self.onSaveFile()
                }) {
                    Image(systemName: "square.and.arrow.down")
                        .font(.system(size: 20, weight: .medium))
                        .frame(width: 28, height: 28)
                        .foregroundColor(.gray)
                }.buttonStyle(PlainButtonStyle())
                    .help("保存到文件")


                Button(action: {
                    self.onSave()
                }) {
                    Image(systemName: "clipboard")
                        .font(.system(size: 20, weight: .medium))
                        .frame(width: 28, height: 28)
                        .foregroundColor(.gray)
                }.buttonStyle(PlainButtonStyle())
                    .help("保存到剪贴板")
            }
            .padding(.horizontal, 12)
            .frame(height: 40)
            .background(.white)
            .cornerRadius(4)
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )
            .shadow(color: .gray.opacity(0.1), radius: 2, x: 0, y: 1)
        }
    }

    func onPinImage () {
        appState.setImageSaveTo(.pin)
        if appState.annotationType == .none {
            EventBus.shared.post(SaveAll(data: "pin"))
        } else {
            EventBus.shared.post(SaveDrawing(data: "pin"))
        }
        appState.annotationType = .none
    }
    func onSave() {
        appState.setImageSaveTo(.pasteboard)
        if appState.annotationType == .none {
            EventBus.shared.post(SaveAll(data: "save"))
        } else {
            EventBus.shared.post(SaveDrawing(data: "save"))
        }
        appState.annotationType = .none
    }

    func onSaveDrawing() {
        EventBus.shared.post(SaveDrawing(data: "save"))
    }

    func onSaveAll() {
        EventBus.shared.post(SaveAll(data: "save"))
    }

    func onSaveFile() {
        appState.setImageSaveTo(.file)
        if appState.annotationType == .none {
            EventBus.shared.post(SaveAll(data: "save"))
        } else {
            EventBus.shared.post(SaveDrawing(data: "save"))
        }
        Util.setOverlayWindowLevel(.normal)
    }
}

enum ResizeHandle: CaseIterable {
    case none
    case topLeft, top, topRight, right, bottomRight, bottom, bottomLeft, left

    static var allCases: [ResizeHandle] {
        return [.none, .topLeft, .top, .topRight, .right, .bottomRight, .bottom, .bottomLeft, .left]
    }
}

#Preview {
    ActionBarView()
}
