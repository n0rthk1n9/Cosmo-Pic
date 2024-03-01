//
//  NewFavoriteButtonView.swift
//  CosmoPic
//
//  Created by Jan Armbrust on 01.03.24.
//

import SwiftUI

struct NewFavoriteButtonView: View {
  @EnvironmentObject var viewModel: FavoritesViewModel

  let photo: Photo

  var body: some View {
    if viewModel.isFavorite(photo) {
      Button(action: removeFromFavorites) {
        Image(systemName: "star.fill")
          .font(.title)
          .foregroundColor(.yellow)
          .padding()
      }
    } else {
      Button(action: addToFavorites) {
        Image(systemName: "star")
          .font(.title)
          .foregroundColor(.yellow)
          .padding()
      }
    }
  }

  private func addToFavorites() {
    viewModel.addToFavorites(photo)
  }

  private func removeFromFavorites() {
    viewModel.removeFromFavorites(photo)
  }
}

#Preview {
  NewFavoriteButtonView(photo: .allProperties)
    .environmentObject(FavoritesViewModel())
}
