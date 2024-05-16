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
        if viewModel.favorites.isEmpty && viewModel.recentlyDeletedFavorites.isEmpty {
          Text("No favorites yet")
            .font(.title)
            .foregroundColor(.gray)
            .padding()
            .multilineTextAlignment(.center)
        } else {
          VStack {
            List {
              Section {
                ForEach(searchResults, id: \.title) { photo in
                  NavigationLink(value: photo) {
                    Text(photo.title)
                  }
                }
                .onDelete(perform: delete)
              } header: {
                Text("Favorites")
              }
              Section {
                ForEach(viewModel.recentlyDeletedFavorites, id: \.title) { photo in
                  NavigationLink(value: photo) {
                    Text(photo.title)
                  }
                }
              } header: {
                Text("Recently deleted")
              }
            }
            .listStyle(.sidebar)
            .accessibilityIdentifier("favorites-list")
          }
        }
      }
      .navigationDestination(for: Photo.self) { photo in
        PhotoDetailView(photo: photo)
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
