//
//  WhoisLockedTableViewCell.swift
//  ec3730
//
//  Created by Zachary Gorak on 8/8/19.
//  Copyright © 2019 Zachary Gorak. All rights reserved.
//

import Foundation
import UIKit
import SwiftyStoreKit

fileprivate var cachedPrice: String? = nil
class WhoisLockedTableViewCell: UITableViewCell {
    var iapDelegate: InAppPurchaseUpdateDelegate? = nil

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
    var restoringActivity = UIActivityIndicatorView(style: .gray)
    
    @objc
    func restore(_ sender: UIButton) {
        SwiftyStoreKit.restorePurchases(atomically: true) { results in
            self.isRestoring = false
            
            if results.restoreFailedPurchases.count > 0 {
                print("Restore Failed: \(results.restoreFailedPurchases)")
            }
            else if results.restoredPurchases.count > 0 {
                print("Restore Success: \(results.restoredPurchases)")
            }
            else {
                print("Nothing to Restore")
            }
            
            // Update isSubscribed cache
            let _ = WhoisXml.isSubscribed
            
            self.iapDelegate?.restoreInAppPurchase(results)
        }
    }
    
    @objc func buy(_ sender: UIButton) {
        SwiftyStoreKit.purchaseProduct(WhoisXml.subscriptions.monthly.identifier, quantity: 1, atomically: true, simulatesAskToBuyInSandbox: false) { (result) in
            
            switch result {
            case .success(let product):
                if product.needsFinishTransaction {
                    SwiftyStoreKit.finishTransaction(product.transaction)
                }
                break
            default:
                break
            }
            
            // Update isSubscribed cache
            let _ = WhoisXml.isSubscribed
            
            self.iapDelegate?.updatedInAppPurchase(result)
        }
    }
    
    convenience init(reuseIdentifier: String?) {
        self.init(style: .default, reuseIdentifier: reuseIdentifier)
        
        
        restoringActivity.hidesWhenStopped = true
        //self.heightAnchor.constraint(equalToConstant: self.frame.height * 3).isActive = true
        //self.backgroundColor = UIColor.green
        //self.contentView.backgroundColor = UIColor.red
        
        let stack = UIStackView()
        stack.spacing = 10.0
        stack.axis = .vertical
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.distribution = .fill
        self.contentView.addSubview(stack)
        
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[scrollview]-|", options: .alignAllCenterY, metrics: nil, views: ["scrollview": stack]))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[scrollview]-|", options: .alignAllCenterY, metrics: nil, views: ["scrollview": stack]))
        //stack.topAnchor.constraint(equalTo: self.contentView.topAnchor).isActive = true
        
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
        iconWrap.widthAnchor.constraint(equalToConstant: self.frame.height * 2).isActive = true
        
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
        headline.text = "Unlock WHOIS Lookup"
        headline.font = UIFont.boldSystemFont(ofSize: UIFont.systemFontSize * 2)
        headline.contentMode = .scaleAspectFit
        headline.adjustsFontSizeToFitWidth = true
        
        headline.translatesAutoresizingMaskIntoConstraints = false
        rightStack.addArrangedSubview(headline)
        
        let subtext = UILabel()
        subtext.text = "Our Hosted WHOIS Lookup provides the registration details, also known as a WHOIS Record, of domain names"
        subtext.lineBreakMode = .byWordWrapping
        subtext.contentMode = .scaleToFill
        subtext.numberOfLines = 0
        //subtext.preferredMaxLayoutWidth = (self.contentView.frame.width/3)*2
        rightStack.addArrangedSubview(subtext)
        
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
        //restore.setTitleColor(buttonColor, for: .normal)
        restore.translatesAutoresizingMaskIntoConstraints = false
        buttonStack.addArrangedSubview(restore)
        
        let buy = UIButton(type: .system)
        buy.tintColor = UIColor.white
        buy.setTitle("Purchase", for: .normal)
        buy.addTarget(self, action: #selector(self.buy), for: .touchUpInside)
        buy.contentHorizontalAlignment = .center
        buy.backgroundColor = UIButton(type: .system).tintColor
        buy.layer.cornerRadius = 5.0
        buy.translatesAutoresizingMaskIntoConstraints = false
        
        if let price = cachedPrice {
            buy.setTitle((buy.titleLabel?.text)! + " - " + price, for: .normal)
        } else {
            SwiftyStoreKit.retrieveProductsInfo([WhoisXml.subscriptions.monthly.identifier]) { result in
                if let product = result.retrievedProducts.first {
                    DispatchQueue.main.async {
                        guard let price = product.localizedPrice else {
                            return
                        }
                        
                        cachedPrice = price
                        
                        if #available(iOS 11.2, *) {
                            if let sub = product.subscriptionPeriod {
                                switch sub.unit {
                                case .month:
                                    if sub.numberOfUnits == 1 {
                                        cachedPrice = price + "/month"
                                    } else {
                                        cachedPrice = price + "/" + String(describing: sub.numberOfUnits) + " months"
                                    }
                                    break
                                default:
                                    break
                                }
                            }
                        }
                        
                        buy.setTitle((buy.titleLabel?.text)! + " - " + cachedPrice!, for: .normal)
                    }
                }
                else if let invalidProductId = result.invalidProductIDs.first {
                    print("Invalid product identifier: \(invalidProductId)")
                }
                else {
                    print("Error: \(result.error?.localizedDescription)")
                }
            }
        }
        
        buttonStack.addArrangedSubview(buy)
        
        let termStack = UIStackView()
        termStack.translatesAutoresizingMaskIntoConstraints = false
        termStack.axis = .vertical
        termStack.distribution = .equalCentering
        termStack.spacing = 0.0
        
        let smallText = UILabel()
        // https://developer.apple.com/design/human-interface-guidelines/subscriptions/overview/
        smallText.text = """
Payment will be charged to your Apple ID account at the confirmation of purchase. The subscription automatically renews unless it is canceled at least 24 hours before the end of the current period. Your account will be charged for renewal within 24 hours prior to the end of the current period. You can manage and cancel your subscriptions by going to your App Store account settings after purchase.
"""
        smallText.font = UIFont.systemFont(ofSize: UIFont.smallSystemFontSize)
        smallText.textColor = UIColor.lightGray
        smallText.textAlignment = .justified
        smallText.lineBreakMode = .byWordWrapping
        smallText.numberOfLines = 0
        termStack.addArrangedSubview(smallText)
        
        let termStackInner = UIStackView()
        termStackInner.translatesAutoresizingMaskIntoConstraints = false
        termStackInner.axis = .horizontal
        termStackInner.distribution = .equalCentering
        termStackInner.spacing = 16.0
        termStack.addArrangedSubview(termStackInner)
        
        let privacy = UIButton()
        privacy.setAttributedTitle(NSAttributedString(string: "Privacy Policy", attributes: [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue, NSAttributedString.Key.foregroundColor: smallText.textColor as Any]), for: .normal)
        privacy.titleLabel?.textAlignment = .center
        privacy.titleLabel?.font = smallText.font
        privacy.addTarget(self, action: #selector(clickPrivacy(_:)), for: .touchUpInside)
        termStackInner.addArrangedSubview(privacy)
        
        let tos = UIButton()
        tos.setAttributedTitle(NSAttributedString(string: "Terms of Use", attributes: [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue, NSAttributedString.Key.foregroundColor: smallText.textColor as Any]), for: .normal)
        tos.titleLabel?.textAlignment = .center
        tos.titleLabel?.font = smallText.font
        tos.addTarget(self, action: #selector(clickToS(_:)), for: .touchUpInside)
        termStackInner.addArrangedSubview(tos)
        
        stack.addArrangedSubview(termStack)
        
        self.separatorInset.right = .greatestFiniteMagnitude
    }
    
    @objc func clickPrivacy(_ sender: UIButton) {
        UIApplication.shared.open(URL(string: "https://zac.gorak.us/ios/privacy.html")!, options: [:], completionHandler: nil)
    }
    
    @objc func clickToS(_ sender: UIButton) {
        UIApplication.shared.open(URL(string: "https://zac.gorak.us/ios/terms.html")!, options: [:], completionHandler: nil)
    }
}
