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
        VStack {
          if viewModel.saveCompleted {
            Image(systemName: "checkmark")
              .font(.title)
              .foregroundColor(.green)
          } else {
            Image(systemName: "square.and.arrow.down")
              .font(.title)
              .foregroundColor(viewModel.isSaving ? .gray : .white)
          }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(Circle())
        .padding()
      }
    )
    .disabled(viewModel.isSaving || viewModel.saveCompleted)
    .showCustomAlert(alert: $viewModel.error)
  }
}

#Preview {
  SaveButtonView(photoURL: nil)
}
