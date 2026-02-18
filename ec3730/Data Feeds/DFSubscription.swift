//
//  DFSubscription.swift
//  ec3730
//
//  Created by Zachary Gorak on 10/16/19.
//  Copyright © 2019 Zachary Gorak. All rights reserved.
//

import Foundation
import StoreKit

open class Subscription {
    var identifier: String
    var product: Product?

    init(_ identifier: String) {
        self.identifier = identifier
        Task {
            await retrieveProduct()
            await verifySubscription()
        }
    }

    public var session = URLSession.shared
    private var cachedExpirationDate: Date?

    public var isSubscribed: Bool {
        #if DEBUG
            if UserDefaults.standard.bool(forKey: "FASTLANE_SNAPSHOT") {
                return true
            }
        #endif

        guard let expiration = cachedExpirationDate else {
            Task { await verifySubscription() }
            return false
        }

        let state = expiration.timeIntervalSinceNow > 0

        if !state {
            Task { await verifySubscription() }
        }

        return state
    }

    public func retrieveProduct() async {
        _ = try? await resolveProduct()
    }

    public func verifySubscription() async {
        guard let product = await loadProductIfNeeded() else { return }
        guard let transaction = await product.latestTransaction else {
            cachedExpirationDate = nil
            return
        }

        do {
            let verified = try checkVerified(transaction)
            await updateSubscriptionStatus(verified)
        } catch {
            cachedExpirationDate = nil
        }
    }

    public func buy() async throws -> Transaction? {
        let product = try await resolveProduct()
        let result = try await product.purchase()

        switch result {
        case let .success(verification):
            let transaction = try checkVerified(verification)
            await updateSubscriptionStatus(transaction)
            await transaction.finish()
            return transaction
        case .userCancelled, .pending:
            return nil
        @unknown default:
            return nil
        }
    }

    public func restore() async throws {
        try await AppStore.sync()
        await verifySubscription()
    }

    private func loadProductIfNeeded() async -> Product? {
        if let product {
            return product
        }
        await retrieveProduct()
        return product
    }

    private func resolveProduct() async throws -> Product {
        if let product {
            return product
        }
        let products = try await Product.products(for: [identifier])
        guard let product = products.first else {
            throw DataFeedError.invalidProduct(id: identifier)
        }
        self.product = product
        return product
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw SKError(.clientInvalid)
        case let .verified(safe):
            return safe
        }
    }

    private func updateSubscriptionStatus(_ transaction: Transaction) async {
        if transaction.revocationDate == nil {
            if let expirationDate = transaction.expirationDate {
                cachedExpirationDate = expirationDate
            }
        } else {
            cachedExpirationDate = nil
        }
    }
}
