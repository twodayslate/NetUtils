//
//  CopyDetailCell.swift
//  ec3730
//
//  Created by Zachary Gorak on 8/12/19.
//  Copyright © 2019 Zachary Gorak. All rights reserved.
//

import Foundation
import UIKit

class CopyCell: UITableViewCell {
    var titleLabel: CopyLabel?
    var detailLabel: CopyLabel?
    var stack: UIStackView

    init(title: String, detail: String? = nil) {
        stack = UIStackView()
        super.init(style: .default, reuseIdentifier: title)

        stack.spacing = 10.0
        stack.axis = .horizontal
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.distribution = .fill
        contentView.addSubview(stack)

        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[scrollview]-|", options: .alignAllCenterY, metrics: nil, views: ["scrollview": stack]))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[scrollview]-|", options: .alignAllCenterY, metrics: nil, views: ["scrollview": stack]))

        titleLabel = CopyLabel()
        titleLabel?.text = title
        titleLabel?.font = UITableViewCell(style: .value1, reuseIdentifier: "reused").textLabel?.font
        titleLabel?.textColor = UITableViewCell(style: .value1, reuseIdentifier: "reused").textLabel?.textColor
        // titleLabel?.font = UIFont.boldSystemFont(ofSize: UIFont.systemFontSize)

        detailLabel = CopyLabel()
        detailLabel?.text = detail
        detailLabel?.textAlignment = .right
        detailLabel?.font = UITableViewCell(style: .value1, reuseIdentifier: "reused").detailTextLabel?.font
        detailLabel?.textColor = UITableViewCell(style: .value1, reuseIdentifier: "reused").detailTextLabel?.textColor
        detailLabel?.adjustsFontSizeToFitWidth = true

        let hold = UILongPressGestureRecognizer(target: titleLabel!, action: #selector(titleLabel!.copyAction(_:)))
        hold.isEnabled = true
        titleLabel?.isUserInteractionEnabled = true
        titleLabel?.addGestureRecognizer(hold)

        stack.addArrangedSubview(titleLabel!)
        stack.addArrangedSubview(detailLabel!)

        titleLabel?.widthAnchor.constraint(greaterThanOrEqualTo: stack.widthAnchor, multiplier: 0.25).isActive = true
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
