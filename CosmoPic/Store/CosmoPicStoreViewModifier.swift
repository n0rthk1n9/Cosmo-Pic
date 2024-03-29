//
//  CosmoPicStoreViewModifier.swift
//  CosmoPic
//
//  Created by Jan Armbrust on 07.03.24.
//

import SwiftUI

struct CosmoPicStoreViewModifier: ViewModifier {
  func body(content: Content) -> some View {
    ZStack {
      content
    }
    .task {
      PurchaseManager.shared.observeTransactionUpdates()
      await PurchaseManager.shared.checkForUnfinishedTransactions()
      await PurchaseManager.shared.refreshPurchasedProducts()
    }
  }
}
