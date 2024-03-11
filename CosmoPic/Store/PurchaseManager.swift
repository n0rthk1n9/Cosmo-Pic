//
//  PurchaseManager.swift
//  CosmoPic
//
//  Created by Jan Armbrust on 07.03.24.
//

import StoreKit

class PurchaseManager: ObservableObject {
  @Published var isShareAndSaveCustomer = false

  private var updatesTask: Task<Void, Never>?

  static let shared = PurchaseManager()

  private init() {}

  @MainActor
  private func setIsShareAndSaveCustomer() {
    isShareAndSaveCustomer.toggle()
  }

  func process(transaction verificationResult: VerificationResult<Transaction>) async {
    let transaction: Transaction

    switch verificationResult {
    case let .verified(trans):
      transaction = trans
      Task {
        await setIsShareAndSaveCustomer()
      }
    case .unverified:
      return
    }

    await transaction.finish()
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

  func refreshPurchasedProducts() async {
    for await verificationResult in Transaction.currentEntitlements {
      switch verificationResult {
      case .verified:
        Task {
          await setIsShareAndSaveCustomer()
        }
      case .unverified:
        return
      }
    }
  }
}
