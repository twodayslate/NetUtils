//
//  SKProductSubscriptionPeriod.swift
//  ec3730
//
//  Created by Zachary Gorak on 10/15/19.
//  Copyright © 2019 Zachary Gorak. All rights reserved.
//

import Foundation
import StoreKit

extension Product {
    func attributedText(subscriber: DataFeedPurchaseProtocol) -> NSAttributedString {
        if let intro = subscription?.introductoryOffer {
            let string = NSMutableAttributedString(string: "")
            if intro.paymentMode == .freeTrial {
                let bold = "Start your free \(intro.period.localizedDescription.lowercased()) trial "
                let boldAttr = NSAttributedString(string: bold, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: UIFont.systemFontSize, weight: .bold),
                                                                             NSAttributedString.Key.foregroundColor: UIColor.systemGray])

                string.append(boldAttr)

                let unbold = "then all \(subscriber.name) Data is available for \(displayPrice)/\(subscription?.subscriptionPeriod.unit.localizedDescription.lowercased() ?? "-") automatically"
                let unboldAttr = NSAttributedString(string: unbold, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: UIFont.systemFontSize, weight: .regular), NSAttributedString.Key.foregroundColor: UIColor.systemGray])
                string.append(unboldAttr)

                return string
            }
        }
        return NSAttributedString(string: "All \(subscriber.name) data is available for \(displayPrice)", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: UIFont.systemFontSize, weight: .regular), NSAttributedString.Key.foregroundColor: UIColor.systemGray])
    }
}

extension Product.SubscriptionPeriod.Unit {
    var localizedDescription: String {
        switch self {
        case .day:
            return "Day"
        case .month:
            return "Month"
        case .week:
            return "Week"
        case .year:
            return "Year"
        @unknown default:
            return "Period"
        }
    }

    var localizedAdjectiveDescription: String {
        switch self {
        case .day:
            return "Daily"
        case .month:
            return "Monthly"
        case .week:
            return "Weekly"
        case .year:
            return "Yearly"
        @unknown default:
            return "Periodic"
        }
    }
}

extension Product.SubscriptionPeriod {
    var localizedDescription: String {
        var unitName = unit.localizedDescription

        if value > 1 {
            unitName = "\(value)-" + unitName
        }

        return unitName
    }
}
