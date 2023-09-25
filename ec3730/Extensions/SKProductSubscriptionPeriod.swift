//
//  SKProductSubscriptionPeriod.swift
//  ec3730
//
//  Created by Zachary Gorak on 10/15/19.
//  Copyright © 2019 Zachary Gorak. All rights reserved.
//

import Foundation
import StoreKit

extension SKProduct {
    func attributedText(subscriber: DataFeedPurchaseProtocol) -> NSAttributedString {
        if let intro = introductoryPrice {
            // **Start your free 3-day trial** then all WHOISXML Data is available for $0.99/month automatically
            let string = NSMutableAttributedString(string: "")
            if intro.paymentMode == .freeTrial {
                let bold = "Start your free \(intro.subscriptionPeriod.localizedDescription.lowercased()) trial "
                // swiftlint:disable:next line_length
                let boldAttr = NSAttributedString(string: bold, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: UIFont.systemFontSize, weight: .bold),
                                                                             NSAttributedString.Key.foregroundColor: UIColor.systemGray])

                string.append(boldAttr)

                let unbold = "then all \(subscriber.name) Data is available for \(localizedPrice ?? "-")/\(subscriptionPeriod?.unit.localizedDescription.lowercased() ?? "-") automatically"
                // swiftlint:disable:next line_length
                let unboldAttr = NSAttributedString(string: unbold, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: UIFont.systemFontSize, weight: .regular), NSAttributedString.Key.foregroundColor: UIColor.systemGray])
                string.append(unboldAttr)

                return string
            }
        }
        return NSAttributedString(string: "All \(subscriber.name) data is available for \(localizedPrice ?? "-")", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: UIFont.systemFontSize, weight: .regular), NSAttributedString.Key.foregroundColor: UIColor.systemGray])
    }
}

extension SKProduct.PeriodUnit {
    var localizedDescription: String {
        var unitName = ""
        switch self {
        case .day:
            unitName = "Day"
        case .month:
            unitName = "Month"
        case .week:
            unitName = "Week"
        case .year:
            return "Year"
        @unknown default:
            break
        }

        return unitName
    }

    var localizedAdjectiveDescription: String {
        var unitName = ""
        switch self {
        case .day:
            unitName = "Daily"
        case .month:
            unitName = "Monthly"
        case .week:
            unitName = "Weekly"
        case .year:
            return "Yearly"
        @unknown default:
            break
        }

        return unitName
    }
}

extension SKProductSubscriptionPeriod {
    var localizedDescription: String {
        var unitName = unit.localizedDescription

        if numberOfUnits > 1 {
            unitName = "\(numberOfUnits)-" + unitName
        }

        return unitName
    }
}
