//
//  Purchase.swift
//  Resistor Box
//
//  Created by Mike Griebling on 21 Apr 2018.
//  Copyright © 2018 Solinst Canada. All rights reserved.
//

import Foundation
import StoreKit

public class Purchase : NSObject, SKProductsRequestDelegate {
    
    static var products = [SKProduct]()
    static var bought = [SKPayment]()
    
    var request : SKProductsRequest!  // Apple says we should use a strong pointer
    
    public func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        Purchase.products = response.products
        if response.invalidProductIdentifiers.count > 0 {
            print("Invalid product identifiers : \(response.invalidProductIdentifiers)")
        }
        self.request = nil
    }

    public func requestProducts() {
        let productIDs = Set<String>(arrayLiteral: "MyProduct")
        request = SKProductsRequest(productIdentifiers: productIDs)
        request.delegate = self   // to get a reply
        request.start()
    }
    
    public func buyProduct(_ product : SKProduct) {
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
    }
    
}

extension Purchase : SKPaymentTransactionObserver {
    
    public func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased:
                Purchase.bought.append(transaction.payment)
                print("Purchased: \(transaction.payment.productIdentifier)")
            case .purchasing:
                print("Purchasing \(transaction.transactionIdentifier!) for \(transaction.payment)")
            case .failed:
                print("Transaction failed with error \(String(describing: transaction.error))")
            case .restored:
                if let payment = transaction.original?.payment {
                    Purchase.bought.append(payment)
                }
            case .deferred:
                print("Deferred: waiting for user...")
            }
            queue.finishTransaction(transaction)   // indicate we are done
        }
    }
    
}
