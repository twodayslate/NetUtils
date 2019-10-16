//
//  SKProductSubscriptionPeriod.swift
//  ec3730
//
//  Created by Zachary Gorak on 10/15/19.
//  Copyright © 2019 Zachary Gorak. All rights reserved.
//

import Foundation
import StoreKit

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
