//
//  ShareButtonView.swift
//  CosmoPic
//
//  Created by Jan Armbrust on 03.03.24.
//

import SwiftUI

struct ShareButtonView: View {
  @ObservedObject private var purchaseManager = PurchaseManager.shared

  @State private var storeSheetIsPresented = false

  let photoURL: URL

  var body: some View {
    if purchaseManager.isShareAndSaveCustomer {
      ShareLink(item: photoURL) {
        Image(systemName: "square.and.arrow.up")
          .font(.title)
          .foregroundColor(.white)
          .frame(width: 32, height: 32)
          .padding()
      }
      .background(.ultraThinMaterial)
      .clipShape(Circle())
      .padding(.horizontal)
    } else {
      Button {
        storeSheetIsPresented = true
      } label: {
        Image(systemName: "square.and.arrow.up")
          .font(.title)
          .foregroundColor(.white)
          .frame(width: 32, height: 32)
          .padding()
      }
      .background(.ultraThinMaterial)
      .clipShape(Circle())
      .padding(.horizontal)
      .sheet(isPresented: $storeSheetIsPresented) {
        CosmoPicStoreView(storeSheetIsPresented: $storeSheetIsPresented)
      }
    }
  }
}

#Preview {
  let photoURL = URL(
    string: "https://upload.wikimedia.org/wikipedia/commons/thumb/f/fa/Apple_logo_black.svg/1920px-Apple_logo_black.svg.png"
  )
  if let photoURL {
    return ShareButtonView(
      photoURL: photoURL
    )
  }

  return Text("No url to share")
}
