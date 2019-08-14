//
//  UIView.swift
//  ec3730
//
//  Created by Zachary Gorak on 8/14/19.
//  Copyright © 2019 Zachary Gorak. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    /// https://www.hackingwithswift.com/example-code/uikit/how-to-find-the-view-controller-responsible-for-a-view
    var controller: UIViewController? {
        if let nextResponder = self.next as? UIViewController {
            return nextResponder
        } else if let nextResponder = self.next as? UIView {
            return nextResponder.controller
        } else {
            return nil
        }
    }
}
