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
  @State private var isFavoritesSectionExpanded = true
  @State private var isRecentlyDeletedSectionExpanded = false

  var filteredFavorites: [Photo] {
    if searchText.isEmpty {
      return viewModel.favorites
    } else {
      return viewModel.favorites.filter { $0.title.contains(searchText)
      }
    }
  }

  var filteredRecentlyDeletedFavorites: [Photo] {
    if searchText.isEmpty {
      return viewModel.recentlyDeletedFavorites
    } else {
      return viewModel.recentlyDeletedFavorites.filter { $0.title.contains(searchText)
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
                if isFavoritesSectionExpanded {
                  ForEach(filteredFavorites, id: \.title) { photo in
                    NavigationLink(value: photo) {
                      Text(photo.title)
                    }
                  }
                  .onDelete(perform: deleteFavorite)
                }
              } header: {
                FavoritesListSectionHeader(
                  title: "Favorites",
                  isOn: $isFavoritesSectionExpanded,
                  onLabel: "Hide",
                  offLabel: "Show"
                )
              }
              Section {
                if isRecentlyDeletedSectionExpanded {
                  ForEach(filteredRecentlyDeletedFavorites, id: \.title) { photo in
                    NavigationLink(value: photo) {
                      Text(photo.title)
                    }
                  }
                  .onDelete(perform: deleteRecentlyDeletedFavorite)
                }
              } header: {
                FavoritesListSectionHeader(
                  title: "Recently Deleted (Last 30 days)",
                  isOn: $isRecentlyDeletedSectionExpanded,
                  onLabel: "Hide",
                  offLabel: "Show"
                )
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
      viewModel.loadRecentlyDeletedFavorites()
      viewModel.purgeOldRecentlyDeletedFavorites()
    }
    .searchable(text: $searchText, prompt: "Search for an image title")
    .onChange(of: searchText) { _, newValue in
      if newValue.isEmpty {
        isFavoritesSectionExpanded = true
        isRecentlyDeletedSectionExpanded = false
      } else {
        isFavoritesSectionExpanded = true
        isRecentlyDeletedSectionExpanded = true
      }
    }
  }

  private func deleteFavorite(at offsets: IndexSet) {
    for index in offsets {
      let photo = filteredFavorites[index]
      viewModel.toggleFavoriteStatus(for: photo)
    }
    viewModel.loadFavorites()
  }

  private func deleteRecentlyDeletedFavorite(at offsets: IndexSet) {
    for index in offsets {
      let photo = viewModel.recentlyDeletedFavorites[index]
      viewModel.removeFromRecentlyDeletedFavorites(photo)
    }
    viewModel.loadRecentlyDeletedFavorites()
  }
}

#Preview {
  FavoritesView()
    .environmentObject(FavoritesViewModel())
}
