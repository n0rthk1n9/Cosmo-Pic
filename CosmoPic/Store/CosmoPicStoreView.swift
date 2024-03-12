//
//  CosmoPicStoreView.swift
//  CosmoPic
//
//  Created by Jan Armbrust on 04.03.24.
//

import StoreKit
import SwiftUI

struct CosmoPicStoreView: View {
  @Environment(\.dismiss)
  var dismiss

  let ids = ["dev.xbow.cosmopic.shareandsave"]

  var body: some View {
    StoreView(ids: ids) { _ in
      Image("ShareAndSave")
        .resizable()
        .scaledToFit()
        .clipShape(RoundedRectangle(cornerSize: CGSize(width: 20, height: 10)))
    }
    .storeButton(.visible, for: .restorePurchases)
    .onChange(of: PurchaseManager.shared.isShareAndSaveCustomer) {
      dismiss()
    }
  }
}

#Preview {
  CosmoPicStoreView()
}
