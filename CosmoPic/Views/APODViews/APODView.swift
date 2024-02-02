//
//  APODView.swift
//  CosmoPic
//
//  Created by Jan Armbrust on 24.11.23.
//

import SwiftUI

struct APODView: View {
  @EnvironmentObject var dataStore: DataStore
  @StateObject private var viewModel = APODViewModel() // Assuming APODViewModel is correctly set up to fetch photos.
  @State private var isCurrentPhotoFavorite = false
  @State private var showCheckmark = false
  @State private var showAlert = false

  var body: some View {
    NavigationStack {
      VStack {
        if viewModel.isLoading {
          ProgressView()
        } else if let photo = viewModel.photo {
          APODContentView(
            photo: photo,
            isCurrentPhotoFavorite: $isCurrentPhotoFavorite,
            showCheckmark: $showCheckmark
          )
        } else {
          if let error = viewModel.error {
            // TODO: Refine error Handling
            ContentUnavailableView("No Data available", systemImage: "x.circle")
              .alert("Error", isPresented: Binding<Bool>(
                get: { error != nil },
                set: { _ in viewModel.error = nil }
              ), presenting: error.localizedDescription) { _ in
                Button("OK", role: .cancel) {}
              } message: { message in
                Text(message)
              }
          }
        }
      }
      .navigationTitle("Cosmo Pic")
      .task {
        await initialFetch()
      }
    }
  }

  // Remove after some time!
  func onAppear() {
    dataStore.resetPhoto()
    dataStore.loadFavorites()
  }

  func initialFetch() async {
    await viewModel.fetchPhotoForToday()
    checkIfFavorite()
  }

  func checkIfFavorite() {
    // This checks if the photo fetched by the ViewModel is a favorite in the DataStore
    if let currentPhoto = viewModel.photo {
      isCurrentPhotoFavorite = dataStore.isFavorite(currentPhoto)
    }
  }

  func loadYesterdayPhoto() {
    // This function remains unchanged, it's here for context
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    guard let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date()) else { return }
    let yesterdayString = dateFormatter.string(from: yesterday)

    Task {
      await dataStore.getPhoto(for: yesterdayString)
      checkIfFavorite()
    }
  }
}
