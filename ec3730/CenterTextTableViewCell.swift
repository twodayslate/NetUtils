//
//  CenterTextTableViewCell.swift
//  ec3730
//
//  Created by Zachary Gorak on 10/22/19.
//  Copyright © 2019 Zachary Gorak. All rights reserved.
//

import Foundation
import UIKit

class CenterTextTableViewCell: UITableViewCell {
    var centerLabel = UILabel()

    init() {
        super.init(style: .default, reuseIdentifier: "center")

        centerLabel.textAlignment = .center
        centerLabel.translatesAutoresizingMaskIntoConstraints = false

        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.addArrangedSubview(centerLabel)
        contentView.addSubview(stack)

        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[scrollview]-|", options: .alignAllCenterY, metrics: nil, views: ["scrollview": stack]))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[scrollview]-|", options: .alignAllCenterY, metrics: nil, views: ["scrollview": stack]))
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
