//
//  WhoisLockedTableViewCell.swift
//  ec3730
//
//  Created by Zachary Gorak on 8/8/19.
//  Copyright © 2019 Zachary Gorak. All rights reserved.
//

import Foundation
import StoreKit
import SwiftyStoreKit
import UIKit

private var cachedPrice: String?

class WhoisLockedTableViewCell: UITableViewCell {
    var iapDelegate: DataFeedInAppPurchaseUpdateDelegate?

    var isRestoring = false {
        didSet {
            DispatchQueue.main.async {
                if self.isRestoring {
                    self.restoringActivity.startAnimating()
                } else {
                    self.restoringActivity.stopAnimating()
                }
            }
        }
    }

    var restoringActivity = UIActivityIndicatorView()

    internal let smallText = UITextView()

    @objc
    func restore(_: UIButton) {
        isRestoring = true

        dataFeed.restore { results in
            self.isRestoring = false
            // swiftlint:disable:next line_length
            self.didUpdateInAppPurchase(self.dataFeed, error: nil, purchaseResult: nil, restoreResults: results, verifySubscriptionResult: nil, verifyPurchaseResult: nil, retrieveResults: nil)
        }
    }

    @objc func buy(_: UIButton) {
        isRestoring = true

        // TODO: generalize block

        if let sub = (dataFeed as? DataFeedSubscription), let defaultSub = sub.subscriptions.first {
            defaultSub.buy { result in
                self.isRestoring = false
                // swiftlint:disable:next line_length
                self.iapDelegate?.didUpdateInAppPurchase(self.dataFeed, error: nil, purchaseResult: result, restoreResults: nil, verifySubscriptionResult: nil, verifyPurchaseResult: nil, retrieveResults: nil)
            }
            return
        }

        if let one = (dataFeed as? DataFeedOneTimePurchase) {
            one.oneTime.purchase { result in
                self.isRestoring = false
                // swiftlint:disable:next line_length
                self.iapDelegate?.didUpdateInAppPurchase(self.dataFeed, error: nil, purchaseResult: result, restoreResults: nil, verifySubscriptionResult: nil, verifyPurchaseResult: nil, retrieveResults: nil)
            }
        }
    }

    /// This fixes a bug
    /// https://stackoverflow.com/questions/16868117/uitextview-that-expands-to-text-using-auto-layout
//    override func didMoveToSuperview() {
//        super.didMoveToSuperview()
//
//        smallText.attributedText = smallText.attributedText
//        smallText.sizeToFit()
//        smallText.invalidateIntrinsicContentSize()
//        smallText.superview?.layoutIfNeeded()
//    }

    var dataFeed: DataFeedPurchaseProtocol

    init(_ dataFeed: DataFeedPurchaseProtocol, heading: String, subheading: String) {
        self.dataFeed = dataFeed
        super.init(style: .default, reuseIdentifier: dataFeed.name)

        restoringActivity.hidesWhenStopped = true
        if #available(iOS 13.0, *) {
            restoringActivity.style = .medium
        } else {
            restoringActivity.style = .gray
        }

        // We want to reload this as soon as possible if the product does not exist
        if !self.dataFeed.owned {
            let prod = (self.dataFeed as? DataFeedSubscription)?.subscriptions.first?.product
            if prod == nil {
                (self.dataFeed as? DataFeedSubscription)?.subscriptions[0].retrieveProduct { error in
                    // swiftlint:disable:next line_length
                    self.didUpdateInAppPurchase(self.dataFeed, error: error, purchaseResult: nil, restoreResults: nil, verifySubscriptionResult: nil, verifyPurchaseResult: nil, retrieveResults: nil)
                }
            }

            if !(self.dataFeed is DataFeedSubscription) {
                (self.dataFeed as? DataFeedOneTimePurchase)?.retrieve { error in
                    // swiftlint:disable:next line_length
                    self.didUpdateInAppPurchase(self.dataFeed, error: error, purchaseResult: nil, restoreResults: nil, verifySubscriptionResult: nil, verifyPurchaseResult: nil, retrieveResults: nil)
                }
            }
        }

        // self.heightAnchor.constraint(equalToConstant: self.frame.height * 3).isActive = true
        // self.backgroundColor = UIColor.green
        // self.contentView.backgroundColor = UIColor.red

        let stack = UIStackView()
        stack.spacing = 10.0
        stack.axis = .vertical
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.distribution = .fill
        contentView.addSubview(stack)

        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[scrollview]-|", options: .alignAllCenterY, metrics: nil, views: ["scrollview": stack]))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[scrollview]-|", options: .alignAllCenterY, metrics: nil, views: ["scrollview": stack]))
        // stack.topAnchor.constraint(equalTo: self.contentView.topAnchor).isActive = true

        /*

         +-------------------------------------+
         | stack (vertical)                    |
         | +---------------------------------+ |
         | | mainSTack (horizontal)          | |
         | | +------------+----------------+ | |
         | | | icon       | rightStack     | | |
         | | |            | +------------+ | | |
         | | |            | | headline   | | | |
         | | |            | |            | | | |
         | | |            | +------------+ | | |
         | | |            | | subtext    | | | |
         | | |            | |            | | | |
         | | |            | +------------+ | | |
         | | +------------+----------------+ | |
         | +---------------------------------+ |
         | +---------------------------------+ |
         | | buttonStack (horizontal)        | |
         |

         */

        let mainStack = UIStackView()
        mainStack.axis = .horizontal
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        mainStack.spacing = 10.0
        stack.addArrangedSubview(mainStack)

        let iconWrap = UIView()
        iconWrap.translatesAutoresizingMaskIntoConstraints = false
        mainStack.addArrangedSubview(iconWrap)
        iconWrap.widthAnchor.constraint(equalToConstant: frame.height * 2).isActive = true

        let icon = UIImageView(image: UIImage(systemName: "lock.shield.fill"))
        icon.translatesAutoresizingMaskIntoConstraints = false
        iconWrap.addSubview(icon)
        icon.heightAnchor.constraint(equalTo: iconWrap.widthAnchor, multiplier: 0.8).isActive = true
        icon.widthAnchor.constraint(equalTo: iconWrap.widthAnchor, multiplier: 0.8).isActive = true
        let xConstraint = NSLayoutConstraint(item: icon, attribute: .centerX, relatedBy: .equal, toItem: iconWrap, attribute: .centerX, multiplier: 1, constant: 0)

        let yConstraint = NSLayoutConstraint(item: icon, attribute: .centerY, relatedBy: .equal, toItem: iconWrap, attribute: .centerY, multiplier: 1, constant: 0)

        NSLayoutConstraint.activate([xConstraint, yConstraint])

        let rightStack = UIStackView()
        rightStack.axis = .vertical
        rightStack.translatesAutoresizingMaskIntoConstraints = false
        rightStack.spacing = 10.0
        mainStack.addArrangedSubview(rightStack)

        let headline = UILabel()
        headline.text = heading
        headline.font = UIFont.boldSystemFont(ofSize: UIFont.systemFontSize * 2)
        headline.contentMode = .scaleAspectFit
        headline.adjustsFontSizeToFitWidth = true
        headline.setContentCompressionResistancePriority(.required, for: .vertical)
        headline.translatesAutoresizingMaskIntoConstraints = false
        rightStack.addArrangedSubview(headline)

        let subtext = UILabel()
        subtext.text = subheading
        subtext.lineBreakMode = .byWordWrapping
        subtext.contentMode = .scaleToFill
        subtext.setContentCompressionResistancePriority(.required, for: .vertical)
        subtext.numberOfLines = 0
        // subtext.preferredMaxLayoutWidth = (self.contentView.frame.width/3)*2
        rightStack.addArrangedSubview(subtext)

        let priceLabel = UILabel()
        priceLabel.translatesAutoresizingMaskIntoConstraints = false
        priceLabel.font = UIFont.systemFont(ofSize: UIFont.systemFontSize - 2)
        priceLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        priceLabel.textColor = UIColor.gray
        priceLabel.textAlignment = .center
        priceLabel.numberOfLines = 0
        stack.addArrangedSubview(priceLabel)

        let buttonStack = UIStackView()
        buttonStack.axis = .horizontal
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        buttonStack.spacing = 8.0
        buttonStack.distribution = .fillProportionally
        buttonStack.setContentCompressionResistancePriority(.required, for: .vertical)
        stack.addArrangedSubview(buttonStack)

        buttonStack.addArrangedSubview(restoringActivity)

        let restore = UIButton(type: .system)
        restore.contentHorizontalAlignment = .center
        restore.setTitle("Restore", for: .normal)
        restore.addTarget(self, action: #selector(self.restore), for: .touchDown)
        // restore.setTitleColor(buttonColor, for: .normal)
        restore.translatesAutoresizingMaskIntoConstraints = false
        buttonStack.addArrangedSubview(restore)

        let buy = UIButton(type: .system)
        buy.tintColor = UIColor.white

        if let subscription = self.dataFeed as? DataFeedSubscription {
            if let price = subscription.defaultProduct?.localizedPrice {
                let attString = NSMutableAttributedString(string: "Subscribe Now for \(price)")
                buy.setAttributedTitle(attString, for: .normal)
            } else {
                let attString = NSMutableAttributedString(string: "Subscribe Now")
                buy.setAttributedTitle(attString, for: .normal)
            }
        } else {
            let attString = NSMutableAttributedString(string: "Purchase")
            buy.setAttributedTitle(attString, for: .normal)
        }

        buy.addTarget(self, action: #selector(self.buy), for: .touchUpInside)
        buy.contentHorizontalAlignment = .center
        buy.backgroundColor = UIButton(type: .system).tintColor
        buy.layer.cornerRadius = 5.0
        buy.translatesAutoresizingMaskIntoConstraints = false

        buttonStack.addArrangedSubview(buy)

        priceLabel.text = "Unable to fetching price..."

        setPrice(for: priceLabel)

        if self.dataFeed is DataFeedSubscription {
            let text = IAPFooterView.legaleeze(color: .systemGray4)

            smallText.translatesAutoresizingMaskIntoConstraints = false
            smallText.isEditable = false
            smallText.isScrollEnabled = false
            smallText.linkTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.systemGray3]
            smallText.delegate = self
            smallText.attributedText = text
            smallText.isScrollEnabled = false
            // TODO: fix the sizing issue
            smallText.automaticallyAdjustsScrollIndicatorInsets = false

            stack.addArrangedSubview(smallText)
        }

        separatorInset.right = .greatestFiniteMagnitude
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setPrice(for label: UILabel) {
        DispatchQueue.main.async {
            label.attributedText = self.dataFeed.defaultProduct?.attributedText(subscriber: self.dataFeed)
        }
    }
}

extension WhoisLockedTableViewCell: UITextViewDelegate {
    func textView(_: UITextView, shouldInteractWith URL: URL, in _: NSRange, interaction _: UITextItemInteraction) -> Bool {
        window?.rootViewController?.open(URL, title: "")

        return false
    }
}

extension WhoisLockedTableViewCell: DataFeedInAppPurchaseUpdateDelegate {
    func didUpdateInAppPurchase(_ feed: DataFeed, error: Error?, purchaseResult: PurchaseResult?, restoreResults: RestoreResults?, verifySubscriptionResult: VerifySubscriptionResult?, verifyPurchaseResult: VerifyPurchaseResult?, retrieveResults: RetrieveResults?) {
        // swiftlint:disable:next line_length
        iapDelegate?.didUpdateInAppPurchase(feed, error: error, purchaseResult: purchaseResult, restoreResults: restoreResults, verifySubscriptionResult: verifySubscriptionResult, verifyPurchaseResult: verifyPurchaseResult, retrieveResults: retrieveResults)
    }
}
