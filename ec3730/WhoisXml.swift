//
//  WhoisXml.swift
//  ec3730
//
//  Created by Zachary Gorak on 9/10/18.
//  Copyright © 2018 Zachary Gorak. All rights reserved.
//

import Foundation
import SwiftyStoreKit

class WhoisError: Error {
    private let _message : String
    init(_ message : String = "WHOIS Error") {
        _message = message
    }
}

class WhoisXml {
    public static let api: ApiKey = ApiKey.WhoisXML
    
    public enum subscriptions {
        case monthly
        
        var identifier:String {
            switch self {
                default:
                    return "whois.monthly.auto"
            }
        }
        
        public func retrieveLocalizedPrice(completion block: ((String?, Error?)->())?=nil) {
            SwiftyStoreKit.retrieveProductsInfo([self.identifier]) { result in
                if let product = result.retrievedProducts.first {
                    if let b = block {
                        b(product.localizedPrice!, nil)
                    }
                }
                else if let invalidProductId = result.invalidProductIDs.first {
                    if let b = block {
                        b(nil, WhoisError("Invalid product identifier: \(invalidProductId)"))
                    }
                }
                else {
                    if let b = block {
                        b(nil, result.error)
                    }
                }
            }
        }
    }
    
    private static var _cachedExpirationDate: Date? = nil
    public class var isSubscribed: Bool {
        get {
            if let _ = SwiftyStoreKit.localReceiptData {
                let validator = AppleReceiptValidator(service: .production, sharedSecret: ApiKey.inApp.key)
                SwiftyStoreKit.verifyReceipt(using: validator) { result in
                    switch result {
                    case .success(let receipt):
                        // Verify the purchase of a Subscription
                        let purchaseResult = SwiftyStoreKit.verifySubscriptions(productIds: Set([WhoisXml.subscriptions.monthly.identifier]), inReceipt: receipt)
                        
                        switch purchaseResult {
                        case .purchased(let expiryDate, let items):
                            print("subscription is valid until \(expiryDate)\n\(items)\n")
                            _cachedExpirationDate = expiryDate
                        case .expired(let expiryDate, let items):
                            print("subscription is expired since \(expiryDate)\n\(items)\n")
                        case .notPurchased:
                            print("The user has never purchased subscription")
                        }
                        
                    case .error(let error):
                        print("Receipt verification failed: \(error)")
                    }
                }
                if let d = _cachedExpirationDate {
                    print(d, d.timeIntervalSinceNow)
                    return d.timeIntervalSinceNow > 0
                }
            }
            return false
        }
    }
    
    
}
