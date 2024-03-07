//
//  PurchaseManager.swift
//  CosmoPic
//
//  Created by Jan Armbrust on 07.03.24.
//

import StoreKit

actor PurchaseManager {
  private var updatesTask: Task<Void, Never>?

  private(set) static var shared: PurchaseManager!

  static func createSharedInstance() {
    shared = PurchaseManager()
  }

  func process(transaction verificationResult: VerificationResult<Transaction>) async {
    let transaction: Transaction

    switch verificationResult {
    case let .verified(trans):
      transaction = trans
    case .unverified:
      return
    }

    await transaction.finish()

    await PurchaseStatusPublisher.shared.setPurchaseMade(true)
  }

  func checkForUnfinishedTransactions() async {
    for await transaction in Transaction.unfinished {
      Task.detached(priority: .background) {
        await self.process(transaction: transaction)
      }
    }
  }

  func observeTransactionUpdates() {
    updatesTask = Task { [weak self] in
      for await update in Transaction.updates {
        guard let self else { break }
        await self.process(transaction: update)
      }
    }
  }
}
