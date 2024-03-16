//
//  FavoritesView.swift
//  CosmoPic
//
//  Created by Jan Armbrust on 24.11.23.
//

import SwiftUI

struct FavoritesView: View {
  @EnvironmentObject var viewModel: FavoritesViewModel

  @State private var searchText = ""

  var searchResults: [Photo] {
    if searchText.isEmpty {
      return viewModel.favorites
    } else {
      return viewModel.favorites.filter { $0.title.contains(searchText)
      }
    }
  }

  var body: some View {
    NavigationStack {
      VStack {
        if viewModel.favorites.isEmpty {
          Text("No favorites yet")
            .font(.title)
            .foregroundColor(.gray)
            .padding()
            .multilineTextAlignment(.center)
        } else {
          List {
            ForEach(searchResults, id: \.title) { photo in
              NavigationLink(destination: PhotoDetailView(photo: photo)) {
                Text(photo.title)
              }
            }
            .onDelete(perform: delete)
          }
          .accessibilityIdentifier("favorites-list")
        }
      }
      #if os(visionOS)
      .padding()
      #endif
      .navigationTitle("Favorites 🌟")
    }
    .onAppear {
      viewModel.loadFavorites()
    }
    .searchable(text: $searchText, prompt: "Search for an image title")
  }

  private func delete(at offsets: IndexSet) {
    for index in offsets {
      let photo = viewModel.favorites[index]
      viewModel.toggleFavoriteStatus(for: photo)
    }
  }
}

#Preview {
  FavoritesView()
    .environmentObject(FavoritesViewModel())
}
