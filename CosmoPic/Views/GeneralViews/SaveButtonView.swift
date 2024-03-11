//
//  SaveButtonView.swift
//  CosmoPic
//
//  Created by Jan Armbrust on 03.03.24.
//

import SwiftUI

struct SaveButtonView: View {
  @ObservedObject private var purchaseStatus = PurchaseStatusPublisher.shared
  @ObservedObject private var purchaseManager = PurchaseManager.shared

  @StateObject private var viewModel = SaveButtonViewModel()
  @State private var storeSheetIsPresented = false

  let photoURL: URL?

  var body: some View {
    Button(
      action: {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()

        if purchaseManager.isShareAndSaveCustomer {
          Task {
            await viewModel.saveImage(from: photoURL)
          }
        } else {
          storeSheetIsPresented = true
        }
      }, label: {
        Image(systemName: viewModel.saveCompleted ? "checkmark" : "square.and.arrow.down")
          .font(.title)
          .foregroundColor(viewModel.isSaving ? .gray : viewModel.saveCompleted ? .green : .white)
          .frame(width: 32, height: 32)
          .padding()
      }
    )
    .disabled(viewModel.isSaving || viewModel.saveCompleted)
    .background(.ultraThinMaterial)
    .clipShape(Circle())
    .padding()
    .sheet(isPresented: $storeSheetIsPresented) {
      CosmoPicStoreView(storeSheetIsPresented: $storeSheetIsPresented)
    }
    .showCustomAlert(alert: $viewModel.error)
  }
}

#Preview {
  SaveButtonView(photoURL: nil)
}
