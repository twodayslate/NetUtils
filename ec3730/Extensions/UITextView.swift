//
//  UITextView.swift
//  ec3730
//
//  Created by Zachary Gorak on 8/28/18.
//  Copyright © 2018 Zachary Gorak. All rights reserved.
//

import Foundation
import UIKit

public extension UITextView {
    func scrollToBottom() {
        if !text.isEmpty {
            let location = text.count - 1
            let bottom = NSRange(location: location, length: 1)
            scrollRangeToVisible(bottom)
        }
    }
}
