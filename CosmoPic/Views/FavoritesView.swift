//
//  FavoritesView.swift
//  CosmoPic
//
//  Created by Jan Armbrust on 24.11.23.
//

import SwiftUI

struct FavoritesView: View {
  @EnvironmentObject var dataStore: DataStore

  var body: some View {
    NavigationStack {
      if dataStore.favorites.isEmpty {
        Text("No favorites yet")
          .font(.title)
          .foregroundColor(.gray)
          .padding()
          .multilineTextAlignment(.center)
      } else {
        List {
          ForEach(dataStore.favorites, id: \.title) { photo in
            NavigationLink(destination: PhotoDetailView(photo: photo)) {
              Text(photo.title)
            }
          }
          .onDelete(perform: delete)
        }
        .navigationTitle("Favorites")
      }
    }
    .onAppear {
      dataStore.loadFavorites()
    }
  }

  private func delete(at offsets: IndexSet) {
    for index in offsets {
      let photo = dataStore.favorites[index]
      dataStore.removeFromFavorites(photo)
    }
  }
}

#Preview {
  FavoritesView()
}
