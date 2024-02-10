//
//  PhotoDetailView.swift
//  CosmoPic
//
//  Created by Jan Armbrust on 27.11.23.
//

import SwiftUI

struct PhotoDetailView: View {
  @StateObject private var viewModel = PhotoDetailViewModel()
  @State private var showAlert = false

  let photo: Photo

  var body: some View {
    VStack {
      if viewModel.isLoading {
        ProgressView()
      } else if let photo = viewModel.photo {
        PhotoDetailContentView(photo: photo, fullDetail: true)
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
    .task {
      await viewModel.getPhoto(for: photo.date)
      checkAndPrepareErrorAlert()
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
