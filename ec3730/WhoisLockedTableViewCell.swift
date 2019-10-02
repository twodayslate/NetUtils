//
//  WhoisLockedTableViewCell.swift
//  ec3730
//
//  Created by Zachary Gorak on 8/8/19.
//  Copyright © 2019 Zachary Gorak. All rights reserved.
//

import Foundation
import SwiftyStoreKit
import UIKit

private var cachedPrice: String?
class WhoisLockedTableViewCell: UITableViewCell {
    var iapDelegate: InAppPurchaseUpdateDelegate?

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

    @objc
    func restore(_: UIButton) {
        isRestoring = true
        SwiftyStoreKit.restorePurchases(atomically: true) { results in
            self.isRestoring = false

            if results.restoreFailedPurchases.count > 0 {
                print("Restore Failed: \(results.restoreFailedPurchases)")
            } else if results.restoredPurchases.count > 0 {
                print("Restore Success: \(results.restoredPurchases)")
            } else {
                print("Nothing to Restore")
            }

            // Update isSubscribed cache
            _ = WhoisXml.isSubscribed

            self.iapDelegate?.restoreInAppPurchase(results)
        }
    }

    @objc func buy(_: UIButton) {
        isRestoring = true
        SwiftyStoreKit.purchaseProduct(WhoisXml.Subscriptions.monthly.identifier, quantity: 1, atomically: true, simulatesAskToBuyInSandbox: false) { result in

            self.isRestoring = false

            switch result {
            case let .success(product):
                if product.needsFinishTransaction {
                    SwiftyStoreKit.finishTransaction(product.transaction)
                }
            default:
                break
            }

            // Update isSubscribed cache
            _ = WhoisXml.isSubscribed

            self.iapDelegate?.updatedInAppPurchase(result)
        }
    }

    convenience init(reuseIdentifier: String?, heading: String? = nil, subheading: String? = nil) {
        self.init(style: .default, reuseIdentifier: reuseIdentifier)

        restoringActivity.hidesWhenStopped = true
        if #available(iOS 13.0, *) {
            restoringActivity.style = .medium
        } else {
            restoringActivity.style = .gray
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

        let icon = UIImageView(image: UIImage(named: "Lock"))
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
        headline.text = heading ?? "Unlock WHOIS Lookup"
        headline.font = UIFont.boldSystemFont(ofSize: UIFont.systemFontSize * 2)
        headline.contentMode = .scaleAspectFit
        headline.adjustsFontSizeToFitWidth = true

        headline.translatesAutoresizingMaskIntoConstraints = false
        rightStack.addArrangedSubview(headline)

        let subtext = UILabel()
        subtext.text = subheading ?? "Our Hosted WHOIS Lookup provides the registration details, also known as a WHOIS Record, of domain names"
        subtext.lineBreakMode = .byWordWrapping
        subtext.contentMode = .scaleToFill
        subtext.numberOfLines = 0
        // subtext.preferredMaxLayoutWidth = (self.contentView.frame.width/3)*2
        rightStack.addArrangedSubview(subtext)

        let priceLabel = UILabel()
        priceLabel.translatesAutoresizingMaskIntoConstraints = false
        priceLabel.font = UIFont.systemFont(ofSize: UIFont.systemFontSize - 2)
        priceLabel.textColor = UIColor.gray
        priceLabel.textAlignment = .center
        priceLabel.numberOfLines = 0
        stack.addArrangedSubview(priceLabel)

        let buttonStack = UIStackView()
        buttonStack.axis = .horizontal
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        buttonStack.spacing = 8.0
        buttonStack.distribution = .fillProportionally
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

        let attString = NSMutableAttributedString(string: "Subscribe Now")

        buy.setAttributedTitle(attString, for: .normal)
        buy.addTarget(self, action: #selector(self.buy), for: .touchUpInside)
        buy.contentHorizontalAlignment = .center
        buy.backgroundColor = UIButton(type: .system).tintColor
        buy.layer.cornerRadius = 5.0
        buy.translatesAutoresizingMaskIntoConstraints = false

        buttonStack.addArrangedSubview(buy)

        let termStack = UIStackView()
        termStack.translatesAutoresizingMaskIntoConstraints = false
        termStack.axis = .vertical
        termStack.distribution = .equalCentering
        termStack.spacing = 0.0

        setPrice(for: priceLabel)

        let smallText = UILabel()
        // https://developer.apple.com/design/human-interface-guidelines/subscriptions/overview/
        // swiftlint:disable line_length
        smallText.text = """
        Payment will be charged to your Apple ID account at the confirmation of purchase. The subscription automatically renews unless it is canceled at least 24 hours before the end of the current period. Your account will be charged for renewal within 24 hours prior to the end of the current period. You can manage and cancel your subscriptions by going to your App Store account settings after purchase.
        """
        // swiftlint:enanble line_length
        smallText.font = UIFont.systemFont(ofSize: UIFont.smallSystemFontSize)
        smallText.textColor = UIColor.lightGray
        smallText.textAlignment = .justified
        smallText.lineBreakMode = .byWordWrapping
        smallText.numberOfLines = 0
        smallText.translatesAutoresizingMaskIntoConstraints = false
        termStack.addArrangedSubview(smallText)

        let termStackInner = UIStackView()
        termStackInner.translatesAutoresizingMaskIntoConstraints = false
        termStackInner.axis = .horizontal
        termStackInner.distribution = .equalCentering
        termStackInner.spacing = 16.0
        termStack.addArrangedSubview(termStackInner)

        let privacy = UIButton()
        privacy.setAttributedTitle(
            NSAttributedString(
                string: "Privacy Policy",
                attributes: [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue, NSAttributedString.Key.foregroundColor: smallText.textColor as Any]
            ),
            for: .normal
        )
        privacy.titleLabel?.textAlignment = .center
        privacy.titleLabel?.font = smallText.font
        privacy.addTarget(self, action: #selector(clickPrivacy(_:)), for: .touchUpInside)
        termStackInner.addArrangedSubview(privacy)

        let tos = UIButton()
        tos.setAttributedTitle(
            NSAttributedString(
                string: "Terms of Use",
                attributes: [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue, NSAttributedString.Key.foregroundColor: smallText.textColor as Any]
            ),
            for: .normal
        )
        tos.titleLabel?.textAlignment = .center
        tos.titleLabel?.font = smallText.font
        tos.addTarget(self, action: #selector(clickToS(_:)), for: .touchUpInside)
        termStackInner.addArrangedSubview(tos)

        stack.addArrangedSubview(termStack)

        separatorInset.right = .greatestFiniteMagnitude
    }

    func setPrice(for label: UILabel) {
        if let price = cachedPrice {
            let attString = NSMutableAttributedString(string: """
            Start your free 3-day trial then all Whois XML API data is available for \(price) automatically.
            """)
            attString.addAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: label.font.pointSize, weight: .bold)], range: NSRange(location: 0, length: 27))
            DispatchQueue.main.async {
                label.attributedText = attString
            }
            return
        } else {
            let attString = NSMutableAttributedString(string: """
            Start your free 3-day trial then all Whois XML API data is available for $0.99/month automatically.
            """)
            attString.addAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: label.font.pointSize, weight: .bold)], range: NSRange(location: 0, length: 27))
            DispatchQueue.main.async {
                label.attributedText = attString
            }
            SwiftyStoreKit.retrieveProductsInfo([WhoisXml.Subscriptions.monthly.identifier]) { result in
                guard result.error == nil else {
                    print(result, "error: \(result.error!.localizedDescription)")
                    return
                }

                guard let product = result.retrievedProducts.first else {
                    print("No products retrieved", result)
                    return
                }

                guard let price = product.localizedPrice else {
                    return
                }

                cachedPrice = price

                if #available(iOS 11.2, *) {
                    if let sub = product.subscriptionPeriod {
                        var terms = (single: "", multiple: "")

                        switch sub.unit {
                        case .day:
                            terms = (single: "day", multiple: "days")
                        case .week:
                            terms = (single: "week", multiple: "weeks")
                        case .month:
                            terms = (single: "month", multiple: "months")
                        case .year:
                            terms = (single: "year", multiple: "years")
                        default:
                            break
                        }

                        if !terms.single.isEmpty {
                            if sub.numberOfUnits == 1 {
                                cachedPrice = price + "/" + terms.single
                            } else if sub.numberOfUnits > 1 {
                                cachedPrice = price + "/" + String(describing: sub.numberOfUnits) + " " + terms.multiple
                            }
                        }
                    }
                }

                self.setPrice(for: label)
            }
        }
    }

    @objc func clickPrivacy(_: UIButton) {
        // self.controller.open did not work with Safari
        UIApplication.shared.open(
            URL(string: "https://zac.gorak.us/ios/privacy.html")!,
            options: [:],
            completionHandler: nil
        )
    }

    @objc func clickToS(_: UIButton) {
        // self.controller.open did not work with Safari
        UIApplication.shared.open(
            URL(string: "https://zac.gorak.us/ios/terms.html")!,
            options: [:],
            completionHandler: nil
        )
    }
}
