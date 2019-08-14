//
//  WhoisErrors.swift
//  ec3730
//
//  Created by Zachary Gorak on 8/13/19.
//  Copyright © 2019 Zachary Gorak. All rights reserved.
//

import Foundation

enum WhoisXmlError: Error {
    case invalidUrl
    case invalidProduct(id: String)
    case empty // No data
    case lowBalance(balance: Int)
    case parse // unable to parse data
    case `nil` // found and unexpected
    
    case custom(description: String, reason: String?, suggestion: String?, help: String?)
    
    init(_ with: WhoisXmlError) {
        self = with
    }
}

extension WhoisXmlError: LocalizedError {
    /// A localized message describing what error occurred.
    var errorDescription: String? {
        switch  self {
        case .invalidProduct(let id):
            return "Invalid product identifier \"\(id)\""
        case .custom(let desc, _, _, _):
            return desc
        default:
            return nil
        }
    }
    
    /// A localized message describing the reason for the failure.
    var failureReason: String? {
        switch self {
        case .custom(_, let reason, _, _):
            return reason
        default:
            return nil
        }
    }
    
    /// A localized message describing how one might recover from the failure.
    var recoverySuggestion: String? {
        switch self {
        case .custom(_, _, let suggestion, _):
            return suggestion
        default:
            return nil
        }
    }
    
    /// A localized message providing "help" text if the user requests help.
    var helpAnchor: String? {
        switch self {
        case .custom(_, _, _, let help):
            return help
        default:
            return nil
        }
    }
}

extension WhoisXmlError: RecoverableError {
    func attemptRecovery(optionIndex recoveryOptionIndex: Int) -> Bool {
        return false
    }
    
    var recoveryOptions: [String] {
        return []
    }
}
