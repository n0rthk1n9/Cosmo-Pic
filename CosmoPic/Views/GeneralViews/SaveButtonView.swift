//
//  SaveButtonView.swift
//  CosmoPic
//
//  Created by Jan Armbrust on 03.03.24.
//

import SwiftUI

struct SaveButtonView: View {
  @StateObject private var viewModel = SaveButtonViewModel()

  let photoURL: URL?

  var body: some View {
    Button(
      action: {
        Task {
          await viewModel.saveImage(from: photoURL)
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
    .showCustomAlert(alert: $viewModel.error)
  }
}

#Preview {
  SaveButtonView(photoURL: nil)
}
