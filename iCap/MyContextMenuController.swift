//
//  MyContextMenuController.swift
//  iCap
//
//  Created by 李旭 on 2024/1/29.
//
import Foundation
import Cocoa


class MyContextMenuController: NSViewController {
    @IBOutlet var label: NSTextField!
    weak var delegate: MyContextMenuControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func closeButtonClicked(_ sender: Any) {
        delegate?.myContextMenuView(self)
    }
}

protocol MyContextMenuControllerDelegate:AnyObject {
    func myContextMenuView(_ myContextMenuView: MyContextMenuController)
}
