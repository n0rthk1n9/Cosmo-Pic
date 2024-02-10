//
//  APODView.swift
//  CosmoPic
//
//  Created by Jan Armbrust on 24.11.23.
//

import SwiftUI

struct APODView: View {
  @StateObject private var viewModel = APODViewModel()
  @State private var showAlert = false

  var body: some View {
    NavigationStack {
      VStack {
        if viewModel.isLoading {
          ProgressView()
        } else if let photo = viewModel.photo {
          PhotoDetailContentView(photo: photo)
        } else {
          if let error = viewModel.error {
            ContentUnavailableView("No Data available", systemImage: "x.circle")
              .alert(isPresented: $showAlert) {
                Alert(
                  title: Text("Error"),
                  message: Text(error.localizedDescription),
                  dismissButton: .default(Text("Ok"))
                )
              }
          }
        }
      }
      .navigationTitle("Cosmo Pic")
      .task {
        await viewModel.fetchPhotoForToday()
        checkAndPrepareErrorAlert()
      }
    }
  }

  func checkAndPrepareErrorAlert() {
    if let urlError = viewModel.error as? URLError, urlError.code == .cancelled {
      showAlert = false
    } else if viewModel.error != nil {
      showAlert = true
    }
  }
}
