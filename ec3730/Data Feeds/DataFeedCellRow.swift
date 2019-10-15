//
//  DataFeedCellRow.swift
//  ec3730
//
//  Created by Zachary Gorak on 10/15/19.
//  Copyright © 2019 Zachary Gorak. All rights reserved.
//

import Foundation
import UIKit

class SubscriptionRow: UIStackView {
    var subscription: Subscription

    var title = UILabel()
    var state: DataFeedCellState = .loading {
        didSet {
            if let view = ownedView {
                removeArrangedSubview(view)
                view.removeFromSuperview()
            }

            var checkState = state

            if subscription.isSubscribed {
                checkState = .owned
            }

            switch checkState {
            case .owned:
                let checkmark = UIImage(systemName: "checkmark")
                ownedView = UIImageView(image: checkmark)
            case .loading:
                ownedView = UIActivityIndicatorView(style: .medium)
                (ownedView as? UIActivityIndicatorView)?.startAnimating()
            case let .cost(sub):
                ownedView = UIButton(type: .system)
                ownedView?.backgroundColor = tintColor
                // (ownedView as? UIButton)?.titleLabel?.textColor = backgroundColor ?? UIColor.systemBackground

                (ownedView as? UIButton)?.setTitle(sub.product?.localizedPrice, for: .normal)
                (ownedView as? UIButton)?.setTitleColor(UIColor.systemBackground, for: .normal)
                ownedView?.layer.cornerRadius = 8.0
                (ownedView as? UIButton)?.contentEdgeInsets = UIEdgeInsets(top: 2.0, left: 6.0, bottom: 2.0, right: 6.0)
                (ownedView as? UIButton)?.addTarget(self, action: #selector(purchase(_:)), for: .touchUpInside)
            case .nothing:
                break
            }

            if ownedView != nil {
                addArrangedSubview(ownedView!)
            }
        }
    }

    private var ownedView: UIView?

    init(_ subscription: Subscription) {
        self.subscription = subscription
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false

        addArrangedSubview(title)

        configure()
    }

    func configure() {
        if let product = self.subscription.product {
            title.text = product.subscriptionPeriod?.unit.localizedAdjectiveDescription
            if subscription.isSubscribed {
                state = .owned
            } else {
                state = .cost(subscription: subscription)
            }
        } else {
            title.text = "Retrieving..."
            subscription.retrieveProduct { error in
                guard error == nil else {
                    return
                }

                self.configure()
            }
        }
    }

    @objc func purchase(_: Any?) {
        state = .loading
        subscription.buy { _ in
            self.state = .cost(subscription: self.subscription)
        }
    }

    required init(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
