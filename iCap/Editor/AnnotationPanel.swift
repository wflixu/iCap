//
//  AnnotationPanel.swift
//  iCap
//
//  Created by 李旭 on 2025/12/20.
//

import SwiftUI

struct AnnotationPanel: View {
    @EnvironmentObject var annotationManager: AnnotationManager
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack {
            HStack {
                Text("Annotations")
                    .font(.headline)
                
                Spacer()
                
                Button(action: undoAction) {
                    Image(systemName: "arrow.uturn.backward")
                }
                .disabled(annotationManager.undoStack.isEmpty)
                .help("Undo")
                
                Button(action: redoAction) {
                    Image(systemName: "arrow.uturn.forward")
                }
                .disabled(annotationManager.redoStack.isEmpty)
                .help("Redo")
            }
            .padding(.vertical, 8)
            
            List(selection: $annotationManager.selectedAnnotationId) {
                ForEach(annotationManager.annotations) { annotation in
                    AnnotationRow(annotation: annotation)
                        .tag(annotation.id)
                        .onTapGesture {
                            annotationManager.select(annotation.id)
                        }
                }
                .onDelete(perform: deleteAnnotations)
            }
            
            HStack {
                Button(action: deleteSelected) {
                    Image(systemName: "trash")
                }
                .disabled(annotationManager.selectedAnnotationId == nil)
                .help("Delete selected annotation")
                
                Spacer()
                
                Button(action: bringToFront) {
                    Image(systemName: "square.3.layers.forward")
                }
                .disabled(annotationManager.selectedAnnotationId == nil)
                .help("Bring to front")
                
                Button(action: sendToBack) {
                    Image(systemName: "square.3.layers.backward")
                }
                .disabled(annotationManager.selectedAnnotationId == nil)
                .help("Send to back")
            }
            .padding(.horizontal)
        }
        .frame(minWidth: 200, maxWidth: 250)
    }
    
    private func deleteAnnotations(offsets: IndexSet) {
        for index in offsets {
            let annotation = annotationManager.annotations[index]
            annotationManager.delete(annotation.id)
        }
    }
    
    private func deleteSelected() {
        if let selectedId = annotationManager.selectedAnnotationId {
            annotationManager.delete(selectedId)
        }
    }
    
    private func bringToFront() {
        if let selectedId = annotationManager.selectedAnnotationId {
            annotationManager.move(toFront: selectedId)
        }
    }
    
    private func sendToBack() {
        if let selectedId = annotationManager.selectedAnnotationId {
            annotationManager.move(toBack: selectedId)
        }
    }
    
    private func undoAction() {
        annotationManager.undo()
    }
    
    private func redoAction() {
        annotationManager.redo()
    }
}

struct AnnotationRow: View {
    let annotation: Annotation
    
    var body: some View {
        HStack {
            annotationTypeIcon
            Text(annotationTypeDescription)
            Spacer()
            
            if annotation.isSelected {
                Circle()
                    .fill(Color.blue)
                    .frame(width: 8, height: 8)
                    .help("Selected")
            }
        }
        .padding(4)
        .background(annotation.isSelected ? Color.blue.opacity(0.2) : Color.clear)
        .cornerRadius(4)
    }
    
    private var annotationTypeIcon: some View {
        switch annotation.type {
        case .rect:
            return Image(systemName: "rectangle").foregroundColor(.red)
        case .arrow:
            return Image(systemName: "arrow.right").foregroundColor(.blue)
        case .text:
            return Image(systemName: "textformat").foregroundColor(.green)
        case .number:
            return Image(systemName: "list.number").foregroundColor(.orange)
        case .blur:
            return Image(systemName: "eye.slash").foregroundColor(.purple)
        case .highlight:
            return Image(systemName: "highlighter").foregroundColor(.yellow)
        case .none:
            return Image(systemName: "xmark").foregroundColor(.gray)
        }
    }
    
    private var annotationTypeDescription: String {
        switch annotation.type {
        case .rect: return "Rectangle"
        case .arrow: return "Arrow"
        case .text: return "Text"
        case .number: return "Number"
        case .blur: return "Blur"
        case .highlight: return "Highlight"
        case .none: return "None"
        }
    }
}

#Preview {
    AnnotationPanel()
        .environmentObject(AnnotationManager())
        .environmentObject(AppState.share)
}