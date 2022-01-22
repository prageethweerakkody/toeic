

import Foundation
import StoreKit

class IAPService: NSObject {

    private override init() { }
    static let shared = IAPService()

    var products = [SKProduct]()
    let paymentQueue = SKPaymentQueue.default()

    func getProducts() {
        let products: Set = [IAPProduct.consumable.rawValue]
        let request = SKProductsRequest(productIdentifiers: products)
        request.delegate = self
        request.start()
        paymentQueue.add(self)
    }

    func purchase(product: IAPProduct) {
        guard let ProductToPurchase = products.filter({ $0.productIdentifier == product.rawValue }).first
            else { return }
        let payment = SKPayment(product: ProductToPurchase)
        paymentQueue.add(self)
        paymentQueue.add(payment as SKPayment)
    }
}

extension IAPService: SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        self.products = response.products
        print(response.products)
        for product in response.products {
            print(product.localizedTitle)
            purchase(product: .consumable)
        }
    }
}

extension IAPService: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            print(transaction.transactionState)
            switch transaction.transactionState {
            case.purchased:
                print("purchased")
                
            case .purchasing:
                 print("purchased")
            case .failed:
                 print("purchased")
            case .restored:
                 print("purchased")
            case .deferred:
                 print("purchased")
            }
           
        }
    }
    

}


