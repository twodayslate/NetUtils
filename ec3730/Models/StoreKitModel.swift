import StoreKit
import SwiftUI
import SwiftyStoreKit

enum MoreStoreKitError: Error {
    case NotPurchased
}

@available(iOS 15.0.0, *)
class StoreKitModel: ObservableObject {

    public var defaultPurchaseIdentifier: String
    public var purchaseIdentifiers: [String]
    
    private var productSet: Set<String> {
        var ans = [String]()
        ans.append(defaultPurchaseIdentifier)
        ans.append(contentsOf: purchaseIdentifiers)
        return Set(ans)
    }
    
    @Published public private(set) var products: [Product]?
    @Published public private(set) var defaultProduct: Product?
    
    @Published private(set) var purchasedIdentifiers = Set<String>()
    var updateListenerTask: Task<Void, Error>? = nil
    
    init(defaultId: String, ids: [String]) {
        self.defaultPurchaseIdentifier = defaultId
        self.purchaseIdentifiers = ids

        //Start a transaction listener as close to app launch as possible so you don't miss any transactions.
        updateListenerTask = listenForTransactions()

        Task {
            //Initialize the store by starting a product request.
            try await retrieve()
        }
    }

    deinit {
        updateListenerTask?.cancel()
    }
    
    func listenForTransactions() -> Task<Void, Error> {
        return Task.detached {
            //Iterate through any transactions which didn't come from a direct call to `purchase()`.
            for await result in Transaction.updates {
                do {
                    let transaction = try self.checkVerified(result)

                    //Deliver content to the user.
                    await self.updatePurchasedIdentifiers(transaction)

                    //Always finish a transaction.
                    await transaction.finish()
                } catch {
                    //StoreKit has a receipt it can read but it failed verification. Don't deliver content to the user.
                    print("Transaction failed verification")
                }
            }
        }
    }
    
    /// App Store sync and update products
    @MainActor
    func restore(completion block: (() -> Void)? = nil) async throws {
        try await AppStore.sync()
        
        try await self.update()
        
        block?()
    }
    
    @MainActor
    /// Update the products and update purchase identifiers
    func update() async throws {
        let products = try await Product.products(for: self.productSet)
        self.products = products
        for product in products {
            if let transaction = await product.latestTransaction {
                try await self.updatePurchasedIdentifiers(transaction.payloadValue)
            } else {
                self.objectWillChange.send()
                // can't get the latest transaction so assume it isn't purchased
                purchasedIdentifiers.remove(product.id)
            }
        }
    }
    
    func purchase(_ product: Product) async throws -> StoreKit.Transaction? {
        //Begin a purchase.
        let result = try await product.purchase()

        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)

            //Deliver content to the user.
            await updatePurchasedIdentifiers(transaction)

            //Always finish a transaction.
            await transaction.finish()

            return transaction
        case .userCancelled, .pending:
            return nil
        default:
            return nil
        }
    }
    
    @MainActor
    func retrieve(completion block: (([Product]) -> Void)? = nil) async throws {
        let products = try await Product.products(for: self.productSet)
        self.products = products
        for product in products {
            if product.id == self.defaultPurchaseIdentifier {
                self.defaultProduct = product
            }
            
            if let transaction = await product.latestTransaction {
                try await self.updatePurchasedIdentifiers(transaction.payloadValue)
            }
            
        }
        block?(products)
    }
    
    func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        //Check if the transaction passes StoreKit verification.
        switch result {
        case .unverified:
            //StoreKit has parsed the JWS but failed verification. Don't deliver content to the user.
            throw SKError(.clientInvalid)
        case .verified(let safe):
            //If the transaction is verified, unwrap and return it.
            return safe
        }
    }

    @MainActor
    func updatePurchasedIdentifiers(_ transaction: StoreKit.Transaction) async {
        self.objectWillChange.send()
        if transaction.revocationDate == nil {
            // check if the purchse is expired
            if let expirationDate = transaction.expirationDate {
                if expirationDate >= Date() {
                    purchasedIdentifiers.insert(transaction.productID)
                } else {
                    purchasedIdentifiers.remove(transaction.productID)
                }
            } else {
                //If the App Store has not revoked the transaction, add it to the list of `purchasedIdentifiers`.
                purchasedIdentifiers.insert(transaction.productID)
            }
        } else {
            //If the App Store has revoked this transaction, remove it from the list of `purchasedIdentifiers`.
            purchasedIdentifiers.remove(transaction.productID)
        }
    }
    
    var owned: Bool {
        return self.purchasedIdentifiers.count > 0
    }
}

@available(iOS 15.0.0, *)
extension StoreKitModel {
    static var whois: StoreKitModel = {
        return StoreKitModel(defaultId: "whois.monthly.auto", ids: ["whois.yearly.auto", "whois.onetime"])
    }()
    
    static var dns: StoreKitModel = .whois
    
    static var monapi: StoreKitModel = {
        return StoreKitModel(defaultId: "monapi.monthly.auto", ids: ["monapi.yearly.auto", "monapi.onetime"])
    }()
    
    static var webrisk: StoreKitModel = {
        return StoreKitModel(defaultId: "googlewebrisk.onetime", ids: [])
    }()
}
