//
//  CosmoPicStoreView.swift
//  CosmoPic
//
//  Created by Jan Armbrust on 04.03.24.
//

import StoreKit
import SwiftUI

struct CosmoPicStoreView: View {
  @Binding var storeSheetIsPresented: Bool

  let ids = ["dev.xbow.cosmopic.shareandsave"]

  var body: some View {
    StoreView(ids: ids)
      .storeButton(.visible, for: .restorePurchases)
      .onInAppPurchaseCompletion { _, purchaseResult in
        guard case let .success(verificationResult) = purchaseResult, case .success = verificationResult
        else {
          return
        }

        await PurchaseManager.shared.observeTransactionUpdates()
        await PurchaseManager.shared.checkForUnfinishedTransactions()
        storeSheetIsPresented = false
      }
  }
}

#Preview {
  CosmoPicStoreView(storeSheetIsPresented: .constant(true))
}
