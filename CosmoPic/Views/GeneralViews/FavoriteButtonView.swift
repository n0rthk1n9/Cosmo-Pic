//
//  FavoriteButtonView.swift
//  CosmoPic
//
//  Created by Jan Armbrust on 01.03.24.
//

import SwiftUI

struct FavoriteButtonView: View {
  @EnvironmentObject var viewModel: FavoritesViewModel

  let photo: Photo

  var body: some View {
    Button(action: {
      let generator = UIImpactFeedbackGenerator(style: .medium)
      generator.impactOccurred()

      withAnimation {
        viewModel.toggleFavoriteStatus(for: photo)
      }
    }, label: {
      Image(systemName: viewModel.isFavorite(photo) ? "star.fill" : "star")
        .font(.title)
        .foregroundColor(.yellow)
        .padding()
    })
    .background(.ultraThinMaterial)
    .clipShape(Circle())
    .padding()
  }
}

#Preview {
  FavoriteButtonView(photo: .allProperties)
    .environmentObject(FavoritesViewModel())
}
