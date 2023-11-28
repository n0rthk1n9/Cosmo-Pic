//
//  FavoritesView.swift
//  CosmoPic
//
//  Created by Jan Armbrust on 24.11.23.
//

import SwiftUI

struct FavoritesView: View {
  @EnvironmentObject var dataStoreNew: DataStoreNew

  var body: some View {
    NavigationStack {
      if dataStoreNew.favorites.isEmpty {
        Text("No favorites yet")
          .font(.title)
          .foregroundColor(.gray)
          .padding()
          .multilineTextAlignment(.center)
      } else {
        List {
          ForEach(dataStoreNew.favorites, id: \.title) { photo in
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
      dataStoreNew.loadFavorites()
    }
  }

  private func delete(at offsets: IndexSet) {
    for index in offsets {
      let photo = dataStoreNew.favorites[index]
      dataStoreNew.removeFromFavorites(photo)
    }
  }
}

#Preview {
  FavoritesView()
}
