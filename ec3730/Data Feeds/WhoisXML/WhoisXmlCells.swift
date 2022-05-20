//
//  WhoisXmlCells.swift
//  ec3730
//
//  Created by Zachary Gorak on 8/8/19.
//  Copyright © 2019 Zachary Gorak. All rights reserved.
//

import Foundation
import SwiftyStoreKit
import UIKit

class ContactCellRow: UIStackView {
    var titleLabel: UILabel
    var detailLabel: CopyLabel
    init(title: String, detail: String) {
        titleLabel = UILabel()
        detailLabel = CopyLabel()

        super.init(frame: .zero)

        titleLabel.text = title
        titleLabel.adjustsFontSizeToFitWidth = true

        detailLabel.text = detail
        detailLabel.textAlignment = .right
        detailLabel.adjustsFontSizeToFitWidth = true

        addArrangedSubview(titleLabel)
        addArrangedSubview(detailLabel)

        titleLabel.widthAnchor.constraint(greaterThanOrEqualTo: widthAnchor, multiplier: 0.25).isActive = true

        let hold = UILongPressGestureRecognizer(target: detailLabel, action: #selector(detailLabel.copyAction(_:)))
        hold.isEnabled = true
        detailLabel.isUserInteractionEnabled = true
        detailLabel.addGestureRecognizer(hold)
    }

    @available(*, unavailable)
    required init(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class ContactCell: UITableViewCell {
    var titleLabel: UILabel?
    var stack: UIStackView

    init(reuseIdentifier: String?, title: String) {
        stack = UIStackView()
        super.init(style: .default, reuseIdentifier: reuseIdentifier)

        stack.spacing = 10.0
        stack.axis = .vertical
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.distribution = .fill
        contentView.addSubview(stack)

        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[scrollview]-|", options: .alignAllCenterY, metrics: nil, views: ["scrollview": stack]))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[scrollview]-|", options: .alignAllCenterY, metrics: nil, views: ["scrollview": stack]))

        titleLabel = UILabel()
        titleLabel?.text = title
        titleLabel?.font = UIFont.boldSystemFont(ofSize: UIFont.systemFontSize)

        stack.addArrangedSubview(titleLabel!)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func addRow(_ row: ContactCellRow) {
        stack.addArrangedSubview(row)
    }
}

class WhoisXmlCellManager: CellManager {
    var currentRecord: WhoisRecord?

    override func askForMoney() {
        if !WhoisXml.current.owned {
            let locked = WhoisLockedTableViewCell(WhoisXml.current, heading: "Unlock WHOIS Lookup",
                                                  subheading: "Our hosted WHOIS Lookup provides the registration details, also known as a WHOIS Record, of domain names")
            locked.iapDelegate = self
            cells = [locked]
        }
    }

    // swiftlint:disable:next cyclomatic_complexity
    func configure(_: WhoisRecord?) {
        stopLoading()
    }

    override func reload() {
        if let prod = dataFeed as? DataFeedPurchaseProtocol {
            if prod.owned {
                configure(currentRecord)
            } else {
                askForMoney()
            }
        }
    }
}
