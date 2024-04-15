//
//  MyContextMenuView.swift
//  iCap
//
//  Created by 李旭 on 2024/1/29.
//

import AppKit
import SwiftUI

struct MyContextMenuView: NSViewControllerRepresentable {
    @Environment(\.presentationMode) var presentationMode
    @Binding var title: String 

    class Coordinator: NSObject, MyContextMenuControllerDelegate {
        var parent: MyContextMenuView

        init(_ parent: MyContextMenuView) {
            self.parent = parent
        }

        func myContextMenuView(_ tvc: MyContextMenuController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }

    func makeNSViewController(context: Context) -> MyContextMenuController {
        let controller = MyContextMenuController()
        controller.delegate = context.coordinator
        return controller
    }

    func updateNSViewController(_ nsViewController: MyContextMenuController, context: Context) {
        nsViewController.label.stringValue =  title

    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
}
