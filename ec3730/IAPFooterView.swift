//
//  IAPFootView.swift
//  ec3730
//
//  Created by Zachary Gorak on 10/15/19.
//  Copyright © 2019 Zachary Gorak. All rights reserved.
//

import Foundation
import UIKit

class IAPFooterView: UITableViewHeaderFooterView {
    let label = UITextView()
    
    /// https://developer.apple.com/design/human-interface-guidelines/subscriptions/overview/
    static func legaleeze(color: UIColor = .systemGray2) -> NSMutableAttributedString {
        //swiftlint:disable line_length
        let text = """
        Payment will be charged to your Apple ID account at the confirmation of purchase. The subscription automatically renews unless it is canceled at least 24 hours before the end of the current period. Your account will be charged for renewal within 24 hours prior to the end of the current period. You can manage and cancel your subscriptions by going to your App Store account settings after purchase.
        """

        let string = NSMutableAttributedString(string: text, attributes: [NSAttributedString.Key.foregroundColor: color])
        
        let privacy = NSAttributedString(string: " Privacy Policy", attributes: [NSAttributedString.Key.link: "https://zac.gorak.us/ios/privacy"])
        string.append(privacy)
        string.append(NSAttributedString(string: " & ", attributes: [NSAttributedString.Key.foregroundColor: color]))
        
        let terms = NSAttributedString(string: "Terms of Use", attributes: [NSAttributedString.Key.link: "https://zac.gorak.us/ios/terms"])
        
        string.append(terms)
        
        return string
    }
    
    init() {
        super.init(reuseIdentifier: "IAPFooterView")
        
        label.isEditable = false
        label.isScrollEnabled = false
        label.translatesAutoresizingMaskIntoConstraints = false
        label.linkTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.systemGray]
        label.backgroundColor = .clear
        
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.addArrangedSubview(label)
                
        label.attributedText = IAPFooterView.legaleeze()
                        
        contentView.addSubview(stack)
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[scrollview]-|", options: .alignAllCenterY, metrics: nil, views: ["scrollview": stack]))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[scrollview]-|", options: .alignAllCenterY, metrics: nil, views: ["scrollview": stack]))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
