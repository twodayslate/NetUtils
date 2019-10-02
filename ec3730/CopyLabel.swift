//
//  CopyLabel.swift
//  ec3730
//
//  Created by Zachary Gorak on 8/12/19.
//  Copyright © 2019 Zachary Gorak. All rights reserved.
//

import Foundation
import UIKit

class CopyLabel: UILabel {
    @objc func copyText(_: AnyObject) {
        UIPasteboard.general.string = text
    }

    @objc func copyAction(_ sender: UIGestureRecognizer) {
        guard let label = sender.view as? CopyLabel else {
            return
        }

        let showPasswordItem = UIMenuItem(title: "Copy", action: #selector(label.copyText(_:)))

        // https://stackoverflow.com/questions/38472461/ios-create-copy-paste-like-popover-uimenucontroller-in-uitableview
        UIMenuController.shared.menuItems?.removeAll()
        UIMenuController.shared.menuItems = [showPasswordItem]
        UIMenuController.shared.update()

        label.becomeFirstResponder()

//        NotificationCenter.default.addObserver(self, selector: #selector(highLightText(_:)), name: UIMenuController.didShowMenuNotification, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(deselectText(_:)), name: UIMenuController.didHideMenuNotification, object: nil)

        let menu = UIMenuController.shared

        // let rect = timeLabel.textRect(forBounds: timeLabel.frame, limitedToNumberOfLines: 0)
        // copyMenu.setTargetRect(rect, in: self)
        // menu.setTargetRect(rect, in: timeLabel)
        menu.setTargetRect(label.frame, in: label.superview!)
        menu.setMenuVisible(true, animated: true)
    }

    override var canBecomeFirstResponder: Bool {
        return true
    }

    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return action == #selector(copyAction(_:)) || super.canPerformAction(action, withSender: sender)
    }
}
