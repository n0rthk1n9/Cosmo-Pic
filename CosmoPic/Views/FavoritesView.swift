//
//  FavoritesView.swift
//  CosmoPic
//
//  Created by Jan Armbrust on 24.11.23.
//

import SwiftUI

struct FavoritesView: View {
  @EnvironmentObject var dataStore: DataStore
  @EnvironmentObject var viewModel: FavoritesViewModel

  var body: some View {
    NavigationStack {
      if viewModel.favorites.isEmpty {
        Text("No favorites yet")
          .font(.title)
          .foregroundColor(.gray)
          .padding()
          .multilineTextAlignment(.center)
      } else {
        List {
          ForEach(viewModel.favorites, id: \.title) { photo in
            NavigationLink(destination: PhotoDetailView(photo: photo)) {
              Text(photo.title)
            }
          }
          .onDelete(perform: delete)
        }
        .navigationTitle("Favorites")
        .accessibilityIdentifier("favorites-list")
      }
    }
    .onAppear {
      viewModel.loadFavorites()
    }
  }

  private func delete(at offsets: IndexSet) {
    for index in offsets {
      let photo = viewModel.favorites[index]
      viewModel.removeFromFavorites(photo)
    }
  }
}
