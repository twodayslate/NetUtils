//
//  DFOneTimePurchase.swift
//  ec3730
//
//  Created by Zachary Gorak on 10/16/19.
//  Copyright © 2019 Zachary Gorak. All rights reserved.
//

import Foundation
import StoreKit

open class OneTimePurchase {
    var identifier: String
    var product: Product?

    private var privatePurchased: Bool = false
    var purchased: Bool {
        privatePurchased
    }

    init(_ identifier: String) {
        self.identifier = identifier
        Task {
            await retrieveProduct()
            await verifyPurchase()
        }
    }

    func purchase() async throws -> Transaction? {
        let product = try await resolveProduct()
        let result = try await product.purchase()

        switch result {
        case let .success(verification):
            let transaction = try checkVerified(verification)
            await updatePurchaseStatus(transaction)
            await transaction.finish()
            return transaction
        case .userCancelled, .pending:
            return nil
        @unknown default:
            return nil
        }
    }

    public func verifyPurchase() async {
        guard let product = await loadProductIfNeeded() else { return }
        guard let transaction = await product.latestTransaction else {
            privatePurchased = false
            return
        }

        do {
            let verified = try checkVerified(transaction)
            await updatePurchaseStatus(verified)
        } catch {
            privatePurchased = false
        }
    }

    public func retrieveProduct() async {
        _ = try? await resolveProduct()
    }

    public func restore() async throws {
        try await AppStore.sync()
        await verifyPurchase()
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

    private func updatePurchaseStatus(_ transaction: Transaction) async {
        if transaction.revocationDate == nil {
            privatePurchased = true
        } else {
            privatePurchased = false
        }
    }
}

protocol DataFeedOneTimePurchase: DataFeedPurchaseProtocol {
    var oneTime: OneTimePurchase { get }
}

extension DataFeedOneTimePurchase {
    var paid: Bool {
        oneTime.purchased
    }

    var owned: Bool {
        if userKey != nil {
            return true
        }
        return paid
    }

    var defaultProduct: Product? {
        guard let product = oneTime.product else {
            Task { await retrieve() }
            return nil
        }
        return product
    }

    func restore() async throws {
        try await oneTime.restore()
    }

    func verify() async {
        await oneTime.verifyPurchase()
    }

    func retrieve() async {
        await oneTime.retrieveProduct()
    }
}
