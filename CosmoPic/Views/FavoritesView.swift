//
//  FavoritesView.swift
//  CosmoPic
//
//  Created by Jan Armbrust on 24.11.23.
//

import SwiftUI

struct FavoritesView: View {
  @EnvironmentObject var viewModel: FavoritesViewModel
  @EnvironmentObject var router: Router

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
    NavigationStack(path: $router.path) {
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
              NavigationLink(value: photo) {
                Text(photo.title)
              }
            }
            .onDelete(perform: delete)
          }
          .navigationDestination(for: Photo.self) { photo in
            PhotoDetailView(photo: photo)
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
      let photo = searchResults[index]
      viewModel.toggleFavoriteStatus(for: photo)
    }
    viewModel.loadFavorites()
  }
}

#Preview {
  FavoritesView()
    .environmentObject(FavoritesViewModel())
}
