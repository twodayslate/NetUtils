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

    internal let smallText = UITextView()
    
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
            _ = WhoisXml.owned

            self.iapDelegate?.restoreInAppPurchase(results)
        }
    }

    @objc func buy(_: UIButton) {
        isRestoring = true
        SwiftyStoreKit.purchaseProduct(WhoisXml.subscriptions[0].identifier, quantity: 1, atomically: true, simulatesAskToBuyInSandbox: false) { result in

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
            _ = WhoisXml.paid

            self.iapDelegate?.updatedInAppPurchase(result)
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
        headline.setContentCompressionResistancePriority(.required, for: .vertical)
        headline.translatesAutoresizingMaskIntoConstraints = false
        rightStack.addArrangedSubview(headline)

        let subtext = UILabel()
        subtext.text = subheading ?? "Our hosted WHOIS Lookup provides the registration details, also known as a WHOIS Record, of domain names"
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

        let attString = NSMutableAttributedString(string: "Subscribe Now")

        buy.setAttributedTitle(attString, for: .normal)
        buy.addTarget(self, action: #selector(self.buy), for: .touchUpInside)
        buy.contentHorizontalAlignment = .center
        buy.backgroundColor = UIButton(type: .system).tintColor
        buy.layer.cornerRadius = 5.0
        buy.translatesAutoresizingMaskIntoConstraints = false

        buttonStack.addArrangedSubview(buy)

        setPrice(for: priceLabel)
        
        
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
            SwiftyStoreKit.retrieveProductsInfo([WhoisXml.subscriptions[0].identifier]) { result in
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
}

extension WhoisLockedTableViewCell: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        if let window = UIApplication.shared.windows.first(where: { (window) -> Bool in window.isKeyWindow}) {
            window.rootViewController?.open(URL, title: "")
        }
        
        return false
    }
}
