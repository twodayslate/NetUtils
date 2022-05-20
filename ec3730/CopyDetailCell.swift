//
//  CopyDetailCell.swift
//  ec3730
//
//  Created by Zachary Gorak on 8/12/19.
//  Copyright © 2019 Zachary Gorak. All rights reserved.
//

import Foundation
import UIKit

class CopyDetailCell: UITableViewCell {
    var titleLabel: UILabel?
    var detailLabel: CopyLabel?
    var stack: UIStackView

    init(title: String, detail: String) {
        stack = UIStackView()
        super.init(style: .default, reuseIdentifier: title)

        stack.spacing = 10.0
        stack.axis = .horizontal
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.distribution = .fill
        contentView.addSubview(stack)

        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[scrollview]-|", options: .alignAllCenterY, metrics: nil, views: ["scrollview": stack]))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[scrollview]-|", options: .alignAllCenterY, metrics: nil, views: ["scrollview": stack]))

        titleLabel = UILabel()
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

        let hold = UILongPressGestureRecognizer(target: detailLabel!, action: #selector(detailLabel!.copyAction(_:)))
        hold.isEnabled = true
        detailLabel?.isUserInteractionEnabled = true
        detailLabel?.addGestureRecognizer(hold)

        stack.addArrangedSubview(titleLabel!)
        stack.addArrangedSubview(detailLabel!)

        titleLabel?.widthAnchor.constraint(greaterThanOrEqualTo: stack.widthAnchor, multiplier: 0.25).isActive = true
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func addRow(_ row: ContactCellRow) {
        stack.addArrangedSubview(row)
    }
}
