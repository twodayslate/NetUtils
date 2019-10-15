//
//  DataFeedCell.swift
//  ec3730
//
//  Created by Zachary Gorak on 9/26/19.
//  Copyright © 2019 Zachary Gorak. All rights reserved.
//

import Foundation
import UIKit

enum DataFeedCellState {
    case owned
    case loading
    case cost(subscription: Subscription)
    case nothing
}

class DataFeedCell: UITableViewCell {
    let subscriber: DataFeed.Type

    let name = UILabel()
    let descriptionText = UILabel()
    var state: DataFeedCellState = .nothing {
        willSet {
            if let view = ownedView {
                DispatchQueue.main.async {
                    self.nameStack.removeArrangedSubview(view)
                    view.removeFromSuperview()
                }
            }
        }
        didSet {
            var checkState = state

            if let subscriptions = self.subscriber as? DataFeedSubscription.Type, subscriptions.owned {
                checkState = .owned
            }

            switch checkState {
            case .owned:
                let checkmark = UIImage(systemName: "checkmark")
                ownedView = UIImageView(image: checkmark)
            case .loading:
                ownedView = UIActivityIndicatorView(style: .medium)
                (ownedView as? UIActivityIndicatorView)?.startAnimating()
//            case let .cost(sub):
//                if self.subscriber is DataFeedSubscription.Type {
//                   //
//                } else {
//                    ownedView = UIButton(type: .system)
//                    ownedView?.backgroundColor = self.tintColor
//                    (ownedView as? UIButton)?.setTitle(sub.product?.localizedPrice, for: .normal)
//
//                    (ownedView as? UIButton)?.setTitleColor(self.backgroundColor, for: .normal)
//                    ownedView?.layer.cornerRadius = 8.0
//                    (ownedView as? UIButton)?.contentEdgeInsets = UIEdgeInsets(top: 2.0, left: 6.0, bottom: 2.0, right: 6.0)
//                    (ownedView as? UIButton)?.addTarget(self, action: #selector(self.purchase(_:)), for: .touchUpInside)
//                }
            default:
                break
            }

            DispatchQueue.main.async {
                if self.ownedView != nil {
                    self.nameStack.addArrangedSubview(self.ownedView!)
                }
            }
        }
    }

    private let nameStack = UIStackView()
    private var ownedView: UIView?

    private var subscriptionRows = [SubscriptionRow]()
    private var bigSubButton = UIButton()
    private var firstSubDisclaimer: UILabel?

    init(subscriber: DataFeed.Type) {
        self.subscriber = subscriber

        super.init(style: .value1, reuseIdentifier: subscriber.name)

        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = UIStackView.spacingUseDefault

        nameStack.axis = .horizontal
        nameStack.spacing = UIStackView.spacingUseDefault

        name.text = self.subscriber.name
        name.font = UIFont.boldSystemFont(ofSize: UIFont.labelFontSize + 2)
        nameStack.addArrangedSubview(name)

        stack.addArrangedSubview(nameStack)
        descriptionText.numberOfLines = 0
        descriptionText.font = UIFont.systemFont(ofSize: UIFont.systemFontSize + 2)
        stack.addArrangedSubview(descriptionText)

        if let subscriptions = self.subscriber as? DataFeedSubscription.Type, let _ = subscriptions.subscriptions.first, !subscriptions.paid {
            accessoryType = .disclosureIndicator
            bigSubButton.setTitle("Subscribe Now", for: .normal)
            bigSubButton.translatesAutoresizingMaskIntoConstraints = false
            bigSubButton.addTarget(self, action: #selector(purchase(_:)), for: .touchUpInside)
            bigSubButton.contentHorizontalAlignment = .center
            bigSubButton.backgroundColor = UIButton(type: .system).tintColor
            bigSubButton.layer.cornerRadius = 5.0

            
            
            stack.addArrangedSubview(bigSubButton)
            
            
            firstSubDisclaimer = UILabel()
            firstSubDisclaimer?.textAlignment = .center
            firstSubDisclaimer?.text = self.subscriber.name
            firstSubDisclaimer?.translatesAutoresizingMaskIntoConstraints = false
            stack.addArrangedSubview(firstSubDisclaimer!)
            
            stack.setCustomSpacing(16.0, after: self.descriptionText)
            stack.setCustomSpacing(8.0, after: bigSubButton)
            
        }

        contentView.addSubview(stack)
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[scrollview]-|", options: .alignAllCenterY, metrics: nil, views: ["scrollview": stack]))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[scrollview]-|", options: .alignAllCenterY, metrics: nil, views: ["scrollview": stack]))
    }

    func reload() {
        // self.state = .loading

        if let subscriptions = self.subscriber as? DataFeedSubscription.Type {
            if subscriptions.owned {
                state = .owned
            }

            if let mainSub = subscriptions.subscriptions.first {
                if mainSub.isSubscribed {
                    firstSubDisclaimer?.text = "Thank you for your purchase!"
                } else {
                    if let product = mainSub.product {
                        state = .nothing
                        if let intro = product.introductoryPrice {
                            // **Start your free 3-day trial** then all WHOIS XML Data is available for $0.99/month automatically
                            let string = NSMutableAttributedString(string: "")
                            if intro.paymentMode == .freeTrial {
                                let bold = "Start your free \(intro.subscriptionPeriod.localizedDescription.lowercased()) trial "
                                //swiftlint:disable:next line_length
                                let boldAttr = NSAttributedString(string: bold, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: UIFont.systemFontSize, weight: .bold)])

                                string.append(boldAttr)

                                let unbold = "then all \(subscriber.name) Data is available for \(product.localizedPrice ?? "-")/\(product.subscriptionPeriod?.unit.localizedDescription.lowercased() ?? "-") automatically"
                                let unboldAttr = NSAttributedString(string: unbold, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: UIFont.systemFontSize, weight: .regular)])
                                string.append(unboldAttr)

                                firstSubDisclaimer?.attributedText = string
                            }
                        }
                    }
                }
            }
        }
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func purchase(_: Any?) {
        guard let subscriptions = self.subscriber as? DataFeedSubscription.Type, let defaultSub = subscriptions.subscriptions.first else {
            return
        }

        defaultSub.buy {
            _ in
            //
        }
    }
}
