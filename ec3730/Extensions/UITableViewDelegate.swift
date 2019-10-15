//
//  UITableViewDelegate.swift
//  ec3730
//
//  Created by Zachary Gorak on 10/15/19.
//  Copyright © 2019 Zachary Gorak. All rights reserved.
//

import Foundation
import UIKit

extension UITableViewHeaderFooterView {
    internal static func iapFooter() -> UITextView {
        let label = UITextView()
        label.font = UIFont.systemFont(ofSize: UIFont.smallSystemFontSize)
        label.textColor = UIColor.systemGray2
        label.isEditable = false
        label.isScrollEnabled = false
        //label.numberOfLines = 0
        
        label.contentInset = UIEdgeInsets(top: 1.0, left: 16.0, bottom: 0.0, right: 16.0)
        
        // swiftlint:disable line_length
        let text = """
        Payment will be charged to your Apple ID account at the confirmation of purchase. The subscription automatically renews unless it is canceled at least 24 hours before the end of the current period. Your account will be charged for renewal within 24 hours prior to the end of the current period. You can manage and cancel your subscriptions by going to your App Store account settings after purchase.
        """
        
        let string = NSMutableAttributedString(string: text, attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemGray2])
        
        let privacy = NSAttributedString(string: " Privacy Policy", attributes: [NSAttributedString.Key.link: "https://zac.gorak.us/ios/privacy"])
        string.append(privacy)
        string.append(NSAttributedString(string: " & ", attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemGray2]))
        
        let terms = NSAttributedString(string: "Terms of Use", attributes: [NSAttributedString.Key.link: "https://zac.gorak.us/ios/terms"])
        
        label.linkTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.systemGray]
        
        string.append(terms)
        
        label.attributedText = string
        label.backgroundColor = .clear
        
        return label
    }
}
