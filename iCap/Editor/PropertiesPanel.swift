//
//  PropertiesPanel.swift
//  iCap
//
//  Created by 李旭 on 2025/12/20.
//

import SwiftUI

struct PropertiesPanel: View {
    @EnvironmentObject var annotationManager: AnnotationManager
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack {
            Text("Properties")
                .font(.headline)
                .padding(.vertical, 8)
            
            if let selectedId = annotationManager.selectedAnnotationId,
               let annotation = annotationManager.annotations.first(where: { $0.id == selectedId }) {
                
                Form {
                    // Color picker
                    ColorPicker("Color", selection: Binding(
                        get: { annotation.color },
                        set: { newColor in
                            var updatedAnnotation = annotation
                            updatedAnnotation.color = newColor
                            annotationManager.update(updatedAnnotation)
                        }
                    ))
                    
                    // Line width slider
                    if annotation.type != .text {  // Text annotations might use font size instead
                        Slider(value: Binding(
                            get: { annotation.lineWidth },
                            set: { newWidth in
                                var updatedAnnotation = annotation
                                updatedAnnotation.lineWidth = newWidth
                                annotationManager.update(updatedAnnotation)
                            }
                        ), in: 1...10, label: {
                            Text("Line Width")
                        })
                    }
                    
                    // Opacity slider
                    Slider(value: Binding(
                        get: { annotation.opacity },
                        set: { newOpacity in
                            var updatedAnnotation = annotation
                            updatedAnnotation.opacity = newOpacity
                            annotationManager.update(updatedAnnotation)
                        }
                    ), in: 0...1, label: {
                        Text("Opacity")
                    })
                    
                    // Text field for text annotations
                    if annotation.type == .text {
                        TextField("Text", text: Binding(
                            get: { annotation.text },
                            set: { newText in
                                var updatedAnnotation = annotation
                                updatedAnnotation.text = newText
                                annotationManager.update(updatedAnnotation)
                            }
                        ))

                        Slider(value: Binding(
                            get: { annotation.fontSize },
                            set: { newFontSize in
                                var updatedAnnotation = annotation
                                updatedAnnotation.fontSize = newFontSize
                                annotationManager.update(updatedAnnotation)
                            }
                        ), in: 8...72, label: {
                            Text("Font Size")
                        })
                    }

                    // Rectangle specific controls
                    if annotation.type == .rect {
                        Toggle("Fill", isOn: Binding(
                            get: { annotation.isFilled },
                            set: { isFilled in
                                var updatedAnnotation = annotation
                                updatedAnnotation.isFilled = isFilled
                                annotationManager.update(updatedAnnotation)
                            }
                        ))

                        Picker("Line Style", selection: Binding(
                            get: {
                                if annotation.dashPattern == nil { return "solid" }
                                else if annotation.dashPattern == [5, 5] { return "dashed" }
                                else if annotation.dashPattern == [2, 2] { return "dotted" }
                                else { return "solid" }
                            },
                            set: { style in
                                var updatedAnnotation = annotation
                                switch style {
                                case "solid":
                                    updatedAnnotation.dashPattern = nil
                                case "dashed":
                                    updatedAnnotation.dashPattern = [5, 5]
                                case "dotted":
                                    updatedAnnotation.dashPattern = [2, 2]
                                default:
                                    updatedAnnotation.dashPattern = nil
                                }
                                annotationManager.update(updatedAnnotation)
                            }
                        )) {
                            Text("Solid").tag("solid")
                            Text("Dashed").tag("dashed")
                            Text("Dotted").tag("dotted")
                        }
                    }

                    // Arrow specific controls
                    if annotation.type == .arrow {
                        Picker("Arrow Style", selection: Binding(
                            get: { annotation.arrowStyle },
                            set: { newStyle in
                                var updatedAnnotation = annotation
                                updatedAnnotation.arrowStyle = newStyle
                                annotationManager.update(updatedAnnotation)
                            }
                        )) {
                            Text("Standard").tag(ArrowStyle.standard)
                            Text("Filled").tag(ArrowStyle.filled)
                        }

                        Slider(value: Binding(
                            get: { annotation.arrowHeadSize },
                            set: { newSize in
                                var updatedAnnotation = annotation
                                updatedAnnotation.arrowHeadSize = newSize
                                annotationManager.update(updatedAnnotation)
                            }
                        ), in: 5...20, label: {
                            Text("Arrow Size")
                        })
                    }

                    // Number specific controls
                    if annotation.type == .number {
                        HStack {
                            Text("Number")
                            Spacer()
                            Stepper("", value: Binding(
                                get: { annotation.number },
                                set: { newNumber in
                                    var updatedAnnotation = annotation
                                    updatedAnnotation.number = newNumber
                                    annotationManager.update(updatedAnnotation)
                                }
                            ), in: 1...99)
                            Text("\(annotation.number)")
                                .frame(width: 30)
                        }
                    }

                    // Blur specific controls
                    if annotation.type == .blur {
                        Slider(value: Binding(
                            get: { annotation.blurRadius },
                            set: { newRadius in
                                var updatedAnnotation = annotation
                                updatedAnnotation.blurRadius = newRadius
                                annotationManager.update(updatedAnnotation)
                            }
                        ), in: 5...50, label: {
                            Text("Blur Radius")
                        })
                        Text("\(Int(annotation.blurRadius)) pt")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    // Lock toggle
                    Toggle("Locked", isOn: Binding(
                        get: { annotation.isLocked },
                        set: { isLocked in
                            var updatedAnnotation = annotation
                            updatedAnnotation.isLocked = isLocked
                            annotationManager.update(updatedAnnotation)
                        }
                    ))
                }
            } else {
                Text("Select an annotation to edit properties")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            
            Spacer()
        }
        .padding()
        .frame(minWidth: 200, maxWidth: 250)
    }
}

#Preview {
    PropertiesPanel()
        .environmentObject(AnnotationManager())
        .environmentObject(AppState.share)
}