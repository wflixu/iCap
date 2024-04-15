////
////  MyCustomMenu.swift
////  iCap
////
////  Created by 李旭 on 2024/1/29.
////
//
//import AppKit
//import SwiftUI
//import Cocoa
//
//class MyMenuViewController: NSViewController {
//
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        print("ViewController 的 viewDidLoad() 方法被调用")
//    }
//
//    override func menuWillOpen(for menu: NSMenu) {
//        let newItem = NSMenuItem(title: "自定义菜单项", action: #selector(MyMenuViewController.customMenuItemAction), keyEquivalent: "kkk")
//        newItem.target = self
//
//        let submenu = NSMenu()
//        let subItem1 = NSMenuItem(title: "子菜单项 1", action: #selector(MyMenuViewController.subMenuItem1Action), keyEquivalent: "ddd")
//        submenu.addItem(subItem1)
//
//        let subItem2 = NSMenuItem(title: "子菜单项 2", action: #selector(MyMenuViewController.subMenuItem2Action), keyEquivalent: "sss")
//        submenu.addItem(subItem2)
//
//        newItem.submenu = submenu
//        menu.addItem(newItem)
//    }
//
//    @objc func customMenuItemAction(_ sender: Any) {
//        print("自定义菜单项被点击")
//    }
//
//    @objc func subMenuItem1Action(_ sender: Any) {
//        print("子菜单项 1 被点击")
//    }
//
//    @objc func subMenuItem2Action(_ sender: Any) {
//        print("子菜单项 2 被点击")
//    }
//}
//
//
//struct MyCustomMenuView: NSViewControllerRepresentable {
//
//    func makeUIViewController(context: Context) -> MyMenuViewController {
//        let viewController = MyMenuViewController()
//        return viewController
//    }
//
//    func updateUIViewController(_ uiViewController: MyMenuViewController, context: Context) {
//
//    }
//}
//
