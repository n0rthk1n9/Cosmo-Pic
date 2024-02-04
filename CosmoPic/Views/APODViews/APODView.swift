//
//  APODView.swift
//  CosmoPic
//
//  Created by Jan Armbrust on 24.11.23.
//

import SwiftUI

struct APODView: View {
  @EnvironmentObject var dataStore: DataStore
  @EnvironmentObject var favoritesViewModel: FavoritesViewModel
  @StateObject private var viewModel = APODViewModel()
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
      .onAppear {
        favoritesViewModel.loadFavorites()
      }
    }
  }

  func initialFetch() async {
    await viewModel.fetchPhotoForToday()
    checkIfFavorite()
  }

  func checkIfFavorite() {
    if let currentPhoto = viewModel.photo {
      isCurrentPhotoFavorite = favoritesViewModel.isFavorite(currentPhoto)
    }
  }
}
