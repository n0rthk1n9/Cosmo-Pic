//
//  PhotoDetailView.swift
//  CosmoPic
//
//  Created by Jan Armbrust on 27.11.23.
//

import SwiftUI

struct PhotoDetailView: View {
  @StateObject private var viewModel = PhotoDetailViewModel()

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
            .showCustomAlert(alert: $viewModel.error)
        }
      }
    }
    #if os(visionOS)
    .padding()
    #endif
    .task {
      await viewModel.getPhoto(for: photo.date)
    }
  }
}
