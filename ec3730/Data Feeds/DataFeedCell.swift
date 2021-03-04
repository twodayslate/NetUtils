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

        if let purchase = self.subscriber as? DataFeedPurchaseProtocol {
            if purchase.owned {
                addCheckmark()
            }

            if !purchase.paid {
                if let subscriber = self.subscriber as? DataFeedSubscription {
                    bigSubButton.setTitle("Subscribe Now for \(subscriber.subscriptions.first?.product?.localizedPrice ?? "-")", for: .normal)
                } else {
                    bigSubButton.setTitle("Purchase", for: .normal)
                }
                bigSubButton.translatesAutoresizingMaskIntoConstraints = false
                bigSubButton.addTarget(self, action: #selector(purchase(_:)), for: .touchUpInside)
                bigSubButton.contentHorizontalAlignment = .center
                bigSubButton.backgroundColor = UIButton(type: .system).tintColor
                bigSubButton.layer.cornerRadius = 5.0

                stack.addArrangedSubview(bigSubButton)

                firstSubDisclaimer = UILabel()
                firstSubDisclaimer?.textAlignment = .center
                firstSubDisclaimer?.numberOfLines = 0
                firstSubDisclaimer?.attributedText = purchase.defaultProduct?.attributedText(subscriber: purchase)
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
        guard subscriber is DataFeedPurchaseProtocol else {
            return
        }

        if let subscriptions = self.subscriber as? DataFeedSubscription, let defaultSub = subscriptions.subscriptions.first {
            defaultSub.buy {
                result in

                subscriptions.verifySubscriptions { error in
                    self.iapDelegate?.didUpdateInAppPurchase(self.subscriber, error: error, purchaseResult: result,
                                                             restoreResults: nil, verifySubscriptionResult: nil, verifyPurchaseResult: nil, retrieveResults: nil)
                }
            }
        } else {
            if let one = self.subscriber as? DataFeedOneTimePurchase {
                one.oneTime.purchase { result in
                    self.iapDelegate?.didUpdateInAppPurchase(self.subscriber, error: nil, purchaseResult: result,
                                                             restoreResults: nil, verifySubscriptionResult: nil, verifyPurchaseResult: nil, retrieveResults: nil)
                }
            }
        }
    }
}
