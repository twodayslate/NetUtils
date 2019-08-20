//
//  LoadingCell.swift
//  ec3730
//
//  Created by Zachary Gorak on 8/12/19.
//  Copyright © 2019 Zachary Gorak. All rights reserved.
//

import Foundation
import UIKit

class LoadingCell: UITableViewCell {
    var spinner: UIActivityIndicatorView

    init(reuseIdentifier: String?) {
        spinner = UIActivityIndicatorView(style: .gray)

        super.init(style: .default, reuseIdentifier: reuseIdentifier)

        let stack = UIStackView()
        stack.distribution = .equalCentering
        stack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stack)

        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[scrollview]-|", options: .alignAllCenterY, metrics: nil, views: ["scrollview": stack]))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[scrollview]-|", options: .alignAllCenterY, metrics: nil, views: ["scrollview": stack]))

        spinner.translatesAutoresizingMaskIntoConstraints = false
        stack.addArrangedSubview(spinner)
        spinner.startAnimating()
    }

    convenience init() {
        self.init(reuseIdentifier: "loading")
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
