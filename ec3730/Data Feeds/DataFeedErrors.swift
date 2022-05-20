//
//  WhoisErrors.swift
//  ec3730
//
//  Created by Zachary Gorak on 8/13/19.
//  Copyright © 2019 Zachary Gorak. All rights reserved.
//

import Foundation

enum DataFeedError: Error {
    case invalidUrl
    case invalidProduct(id: String)
    case empty // No data
    case lowBalance(balance: Int)
    case parse // unable to parse data
    case `nil` // found and unexpected

    case custom(description: String, reason: String?, suggestion: String?, help: String?)

    init(_ with: DataFeedError) {
        self = with
    }
}

extension DataFeedError: LocalizedError {
    /// A localized message describing what error occurred.
    var errorDescription: String? {
        switch self {
        case let .invalidProduct(id):
            return "Invalid product identifier \"\(id)\""
        case let .custom(desc, _, _, _):
            return desc
        default:
            return nil
        }
    }

    /// A localized message describing the reason for the failure.
    var failureReason: String? {
        switch self {
        case let .custom(_, reason, _, _):
            return reason
        default:
            return nil
        }
    }

    /// A localized message describing how one might recover from the failure.
    var recoverySuggestion: String? {
        switch self {
        case let .custom(_, _, suggestion, _):
            return suggestion
        default:
            return nil
        }
    }

    /// A localized message providing "help" text if the user requests help.
    var helpAnchor: String? {
        switch self {
        case let .custom(_, _, _, help):
            return help
        default:
            return nil
        }
    }
}

extension DataFeedError: RecoverableError {
    func attemptRecovery(optionIndex _: Int) -> Bool {
        false
    }

    var recoveryOptions: [String] {
        []
    }
}
