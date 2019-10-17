//
//  DataFeedCell.swift
//  ec3730
//
//  Created by Zachary Gorak on 9/26/19.
//  Copyright © 2019 Zachary Gorak. All rights reserved.
//

import Foundation
import UIKit

class DataFeedCell: UITableViewCell {
    let subscriber: DataFeed

    let name = UILabel()
    let descriptionText = UILabel()

    private let nameStack = UIStackView()
    private var ownedView: UIView?

    private var bigSubButton = UIButton()
    private var firstSubDisclaimer: UILabel?

    init(subscriber: DataFeed) {
        self.subscriber = subscriber

        super.init(style: .value1, reuseIdentifier: subscriber.name)

        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 8.0

        nameStack.axis = .horizontal
        nameStack.spacing = UIStackView.spacingUseDefault
        nameStack.translatesAutoresizingMaskIntoConstraints = false

        let leftStack = UIStackView()
        leftStack.translatesAutoresizingMaskIntoConstraints = false
        leftStack.axis = .vertical

        name.text = self.subscriber.name
        name.font = UIFont.boldSystemFont(ofSize: UIFont.labelFontSize + 2)
        leftStack.addArrangedSubview(name)
        name.translatesAutoresizingMaskIntoConstraints = false

        stack.addArrangedSubview(nameStack)
        descriptionText.numberOfLines = 0
        descriptionText.font = UIFont.systemFont(ofSize: UIFont.systemFontSize + 2)
        descriptionText.translatesAutoresizingMaskIntoConstraints = false
        leftStack.addArrangedSubview(descriptionText)
        nameStack.addArrangedSubview(leftStack)

        accessoryType = .disclosureIndicator

        if let subscriptions = self.subscriber as? DataFeedSubscription {
            if subscriptions.owned {
                addCheckmark()
            }

            if !subscriptions.paid {
                bigSubButton.setTitle("Subscribe Now", for: .normal)
                bigSubButton.translatesAutoresizingMaskIntoConstraints = false
                bigSubButton.addTarget(self, action: #selector(purchase(_:)), for: .touchUpInside)
                bigSubButton.contentHorizontalAlignment = .center
                bigSubButton.backgroundColor = UIButton(type: .system).tintColor
                bigSubButton.layer.cornerRadius = 5.0

                stack.addArrangedSubview(bigSubButton)

                firstSubDisclaimer = UILabel()
                firstSubDisclaimer?.textAlignment = .center
                firstSubDisclaimer?.numberOfLines = 0
                firstSubDisclaimer?.text = "All \(subscriber.name) Data is available for -/- automatically"
                firstSubDisclaimer?.translatesAutoresizingMaskIntoConstraints = false
                stack.addArrangedSubview(firstSubDisclaimer!)

                stack.setCustomSpacing(16.0, after: descriptionText)
                stack.setCustomSpacing(8.0, after: bigSubButton)

                if let mainSub = subscriptions.subscriptions.first, let product = mainSub.product {
                    let defaultText = "All \(subscriber.name) Data is available for \(product.localizedPrice ?? "-")/\(product.subscriptionPeriod?.unit.localizedDescription.lowercased() ?? "-") automatically"
                    let defaultAttr = NSAttributedString(string: defaultText, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: UIFont.systemFontSize, weight: .regular)])
                    firstSubDisclaimer?.attributedText = defaultAttr

                    if let intro = product.introductoryPrice {
                        // **Start your free 3-day trial** then all WHOIS XML Data is available for $0.99/month automatically
                        let string = NSMutableAttributedString(string: "")
                        if intro.paymentMode == .freeTrial {
                            let bold = "Start your free \(intro.subscriptionPeriod.localizedDescription.lowercased()) trial "
                            // swiftlint:disable:next line_length
                            let boldAttr = NSAttributedString(string: bold, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: UIFont.systemFontSize, weight: .bold),
                                                                                         NSAttributedString.Key.foregroundColor: UIColor.systemGray])

                            string.append(boldAttr)

                            let unbold = "then all \(subscriber.name) Data is available for \(product.localizedPrice ?? "-")/\(product.subscriptionPeriod?.unit.localizedDescription.lowercased() ?? "-") automatically"
                            // swiftlint:disable:next line_length
                            let unboldAttr = NSAttributedString(string: unbold, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: UIFont.systemFontSize, weight: .regular), NSAttributedString.Key.foregroundColor: UIColor.systemGray])
                            string.append(unboldAttr)

                            firstSubDisclaimer?.attributedText = string
                        } // has a free trial
                    } // has an intro price
                } // has a product
            } // is paid
        } // is a subscriber type
        else if let oneTime = self.subscriber as? DataFeedOneTimePurchase {
            if oneTime.oneTime.purchased || oneTime.userKey != nil {
                addCheckmark()
            }

            if !oneTime.oneTime.purchased {
                bigSubButton.setTitle("Purchase", for: .normal)
                bigSubButton.translatesAutoresizingMaskIntoConstraints = false
                bigSubButton.addTarget(self, action: #selector(purchase(_:)), for: .touchUpInside)
                bigSubButton.contentHorizontalAlignment = .center
                bigSubButton.backgroundColor = UIButton(type: .system).tintColor
                bigSubButton.layer.cornerRadius = 5.0

                stack.addArrangedSubview(bigSubButton)

                firstSubDisclaimer = UILabel()
                firstSubDisclaimer?.textAlignment = .center
                firstSubDisclaimer?.numberOfLines = 0
                firstSubDisclaimer?.attributedText = NSAttributedString(string: "All \(subscriber.name) Data is available for \(oneTime.oneTime.product?.localizedPrice ?? "-")", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: UIFont.systemFontSize, weight: .regular), NSAttributedString.Key.foregroundColor: UIColor.systemGray])

                firstSubDisclaimer?.translatesAutoresizingMaskIntoConstraints = false
                stack.addArrangedSubview(firstSubDisclaimer!)

                stack.setCustomSpacing(16.0, after: descriptionText)
                stack.setCustomSpacing(8.0, after: bigSubButton)
            }
        }

        contentView.addSubview(stack)
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[scrollview]-|", options: .alignAllCenterY, metrics: nil, views: ["scrollview": stack]))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[scrollview]-|", options: .alignAllCenterY, metrics: nil, views: ["scrollview": stack]))
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func addCheckmark() {
        let checkmarkWrapper = UIView()
        checkmarkWrapper.translatesAutoresizingMaskIntoConstraints = false

        let checkmark = UIImage(systemName: "checkmark")
        let checkmarkView = UIImageView(image: checkmark)
        checkmarkView.translatesAutoresizingMaskIntoConstraints = false
        checkmarkWrapper.addSubview(checkmarkView)
        nameStack.addArrangedSubview(checkmarkWrapper)
        checkmarkWrapper.widthAnchor.constraint(equalToConstant: checkmarkView.frame.width).isActive = true
        checkmarkView.centerYAnchor.constraint(equalTo: checkmarkWrapper.centerYAnchor).isActive = true
        checkmarkView.centerXAnchor.constraint(equalTo: checkmarkWrapper.centerXAnchor).isActive = true
    }

    var iapDelegate: DataFeedInAppPurchaseUpdateDelegate?

    @objc func purchase(_: Any?) {
        guard let subscriptions = self.subscriber as? DataFeedSubscription, let defaultSub = subscriptions.subscriptions.first else {
            return
        }

        defaultSub.buy {
            result in

            subscriptions.verifySubscriptions { error in
                self.iapDelegate?.didUpdateInAppPurchase(self.subscriber, error: error, purchaseResult: result,
                                                         restoreResults: nil, verifySubscriptionResult: nil, verifyPurchaseResult: nil, retrieveResults: nil)
            }
        }
    }
}
