//
//  CosmoPicStoreView.swift
//  CosmoPic
//
//  Created by Jan Armbrust on 04.03.24.
//

import StoreKit
import SwiftUI

struct CosmoPicStoreView: View {
  let ids = ["dev.xbow.cosmopic.shareandsave"]

  var body: some View {
    StoreView(ids: ids)
      .storeButton(.visible, for: .restorePurchases)
  }
}

#Preview {
  CosmoPicStoreView()
}
