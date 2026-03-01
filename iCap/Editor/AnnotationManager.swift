//
//  AnnotationManager.swift
//  iCap
//
//  Created by 李旭 on 2025/12/20.
//

import AppKit
import Foundation
import SwiftUI
import Combine
import UniformTypeIdentifiers

enum AnnotationOperation {
    case add(Annotation)
    case delete(Annotation, at: Int)
    case update(old: Annotation, new: Annotation)
    case deleteAll([Annotation])

    func inverted() -> AnnotationOperation {
        switch self {
        case .add(let annotation):
            // Find the index where this annotation was added
            return .delete(annotation, at: 0) // Index will be updated by manager
        case .delete(let annotation, let index):
            return .add(annotation)
        case .update(let old, let new):
            return .update(old: new, new: old)
        case .deleteAll(let annotations):
            // Return add operations for all deleted annotations
            // For simplicity, return a single operation
            return annotations.isEmpty ? .deleteAll([]) : .add(annotations[0])
        }
    }
}

@MainActor
class AnnotationManager: ObservableObject {
    @Published var annotations: [Annotation] = []
    @Published var selectedAnnotationId: UUID? = nil
    @Published var isEditingText: Bool = false
    @Published var undoStack: [AnnotationOperation] = []
    @Published var redoStack: [AnnotationOperation] = []
    @Published var nextNumber: Int = 1  // 下一个序号值

    // Add annotation
    func add(_ annotation: Annotation) {
        saveToUndoStack(.add(annotation))
        annotations.append(annotation)
    }

    // 添加序号标注
    func addNumberAnnotation(at point: CGPoint) {
        var annotation = Annotation(
            type: .number,
            frame: CGRect(x: point.x - 15, y: point.y - 15, width: 30, height: 30)
        )
        annotation.number = nextNumber
        nextNumber += 1
        add(annotation)
    }

    // 更新序号值
    func updateNumber(_ annotationId: UUID, number: Int) {
        if let index = annotations.firstIndex(where: { $0.id == annotationId }) {
            annotations[index].number = number
        }
    }

    // 重置序号计数器（每次新截图时调用）
    func resetNumberCounter() {
        nextNumber = 1
    }

    // Delete annotation
    func delete(_ annotationId: UUID) {
        if let index = annotations.firstIndex(where: { $0.id == annotationId }) {
            let annotation = annotations[index]
            saveToUndoStack(.delete(annotation, at: index))
            annotations.remove(at: index)
        }
    }

    // Update annotation
    func update(_ annotation: Annotation) {
        if let index = annotations.firstIndex(where: { $0.id == annotation.id }) {
            saveToUndoStack(.update(old: annotations[index], new: annotation))
            annotations[index] = annotation
        }
    }

    // Select annotation
    func select(_ annotationId: UUID?) {
        selectedAnnotationId = annotationId
        // Update selection state in all annotations
        annotations = annotations.map { annotation in
            var updatedAnnotation = annotation
            updatedAnnotation.isSelected = (annotation.id == annotationId)
            return updatedAnnotation
        }
    }

    // Move annotation to front/back
    func move(toFront annotationId: UUID) {
        guard let index = annotations.firstIndex(where: { $0.id == annotationId }) else { return }
        let annotation = annotations.remove(at: index)
        annotations.append(annotation)
    }

    func move(toBack annotationId: UUID) {
        guard let index = annotations.firstIndex(where: { $0.id == annotationId }) else { return }
        let annotation = annotations.remove(at: index)
        annotations.insert(annotation, at: 0)
    }

    // Move annotation by index
    func move(_ annotationId: UUID, to index: Int) {
        guard let currentIndex = annotations.firstIndex(where: { $0.id == annotationId }) else { return }
        let annotation = annotations.remove(at: currentIndex)
        annotations.insert(annotation, at: index)
    }

    // Clear all annotations
    func clear() {
        saveToUndoStack(.deleteAll(annotations))
        annotations.removeAll()
        selectedAnnotationId = nil
    }

    // Undo/Redo functionality
    func undo() {
        guard let operation = undoStack.popLast() else { return }
        redoStack.append(operation.inverted())

        switch operation {
        case .add(let annotation):
            if let index = annotations.firstIndex(where: { $0.id == annotation.id }) {
                annotations.remove(at: index)
            }
        case .delete(let annotation, let index):
            annotations.insert(annotation, at: min(index, annotations.count))
        case .update(let old, _):
            if let index = annotations.firstIndex(where: { $0.id == old.id }) {
                annotations[index] = old
            }
        case .deleteAll(let annotationsToDelete):
            self.annotations = annotationsToDelete
        }
    }

    func redo() {
        guard let operation = redoStack.popLast() else { return }
        undoStack.append(operation.inverted())

        switch operation {
        case .add(let annotation):
            annotations.append(annotation)
        case .delete(let annotation, _):
            if let index = annotations.firstIndex(where: { $0.id == annotation.id }) {
                annotations.remove(at: index)
            }
        case .update(_, let new):
            if let index = annotations.firstIndex(where: { $0.id == new.id }) {
                annotations[index] = new
            }
        case .deleteAll(let annotationsToDelete):
            self.annotations = annotationsToDelete
        }
    }

    private func saveToUndoStack(_ operation: AnnotationOperation) {
        undoStack.append(operation)
        redoStack.removeAll() // Clear redo stack when new operation is added
    }

    // Additional helper methods
    func isSelected(_ annotationId: UUID) -> Bool {
        return selectedAnnotationId == annotationId
    }

    func getSelectedAnnotation() -> Annotation? {
        guard let selectedId = selectedAnnotationId else { return nil }
        return annotations.first { $0.id == selectedId }
    }

    func toggleSelection(_ annotationId: UUID) {
        if selectedAnnotationId == annotationId {
            select(nil)
        } else {
            select(annotationId)
        }
    }
}