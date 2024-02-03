//
//  FavoriteButtonView.swift
//  CosmoPic
//
//  Created by Jan Armbrust on 01.12.23.
//

import SwiftUI

struct FavoriteButtonView: View {
  let photo: Photo
  @Binding var isCurrentPhotoFavorite: Bool
  @Binding var showCheckmark: Bool
  @EnvironmentObject var dataStore: DataStore
  @EnvironmentObject var viewModel: FavoritesViewModel

  var body: some View {
    Button("Add to Favorites") {
      addToFavorites()
    }
    .buttonStyle(.bordered)
    .padding(.top)
    .accessibilityIdentifier("apod-view-favorites-button")
  }

  private func addToFavorites() {
    viewModel.addToFavorites(photo)
    withAnimation {
      showCheckmark = true
      isCurrentPhotoFavorite = true
    }
  }
}
