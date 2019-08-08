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
    
    @objc
    func restore(_ sender: UIButton) {
        SwiftyStoreKit.restorePurchases(atomically: true) { results in
            if results.restoreFailedPurchases.count > 0 {
                print("Restore Failed: \(results.restoreFailedPurchases)")
            }
            else if results.restoredPurchases.count > 0 {
                print("Restore Success: \(results.restoredPurchases)")
            }
            else {
                print("Nothing to Restore")
            }
        }
    }
    
    
    
    convenience init(reuseIdentifier: String?) {
        self.init(style: .default, reuseIdentifier: reuseIdentifier)
        
        self.heightAnchor.constraint(equalToConstant: self.frame.height * 3).isActive = true
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
        buttonStack.spacing = 10.0
        buttonStack.distribution = .fillEqually
        stack.addArrangedSubview(buttonStack)
        
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
        buy.contentHorizontalAlignment = .center
        buy.backgroundColor = UIButton(type: .system).tintColor
        buy.layer.cornerRadius = 5.0
        buy.translatesAutoresizingMaskIntoConstraints = false
        
        if let price = cachedPrice {
            buy.setTitle((buy.titleLabel?.text)! + " - " + price, for: .normal)
        } else {
            SwiftyStoreKit.retrieveProductsInfo(["whois.monthly.auto"]) { result in
                if let product = result.retrievedProducts.first {
                    DispatchQueue.main.async {
                        guard let price = product.localizedPrice else {
                            return
                        }
                        cachedPrice = price
                        buy.setTitle((buy.titleLabel?.text)! + " - " + price, for: .normal)
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
        
        let smallText = UILabel()
        smallText.text = "Purchasing results in a monthly subscription for WHOIS Lookup which can be canceled at any time"
        smallText.font = UIFont.systemFont(ofSize: UIFont.smallSystemFontSize)
        smallText.textColor = UIColor.gray
        smallText.textAlignment = .center
        smallText.lineBreakMode = .byWordWrapping
        smallText.numberOfLines = 0
        stack.addArrangedSubview(smallText)
        
        self.separatorInset.right = .greatestFiniteMagnitude
        
        
        //        self.imageView?.image = UIImage(named: "Lock")
        //        self.textLabel?.text = "test"
        
        
        //self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[scrollview]-|", options: .alignAllCenterY, metrics: nil, views: ["scrollview": stack]))
        //self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[scrollview]-|", options: .alignAllCenterY, metrics: nil, views: ["scrollview": stack]))
    }
}
