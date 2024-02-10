//
//  PhotoDetailContentView.swift
//  CosmoPic
//
//  Created by Jan Armbrust on 10.02.24.
//

import SwiftUI

struct PhotoDetailContentView: View {
  @EnvironmentObject var favoritesViewModel: FavoritesViewModel
  @State private var isCurrentPhotoFavorite = false
  @State private var showCheckmark = false

  let photo: Photo
  var fullDetail = false

  var body: some View {
    ScrollView {
      if fullDetail {
        VStack(alignment: .leading) {
          Text(photo.title)
            .font(.title)
            .padding(.horizontal)

          DynamicPhotoView(photo: photo)

          HStack {
            Spacer()
            if showCheckmark {
              CheckmarkView(showCheckmark: $showCheckmark)
            } else if !isCurrentPhotoFavorite {
              FavoriteButtonView(
                photo: photo,
                isCurrentPhotoFavorite: $isCurrentPhotoFavorite,
                showCheckmark: $showCheckmark
              )
            }
            Spacer()
          }
          Text(photo.explanation)
            .padding()
            .accessibilityIdentifier("photo-detail-view-photo-explanation")
        }
        .navigationTitle(DateFormatter.localizedDateString(from: photo.date))
      } else {
        VStack(alignment: .center) {
          Text(DateFormatter.localizedDateString(from: photo.date))
            .font(.largeTitle)

          DynamicPhotoView(photo: photo)
            .accessibilityIdentifier("apod-view-photo")

          Text(photo.title)
            .padding([.top, .trailing, .leading])
            .font(.title2)

          if showCheckmark {
            CheckmarkView(showCheckmark: $showCheckmark)
          } else if !isCurrentPhotoFavorite {
            FavoriteButtonView(
              photo: photo,
              isCurrentPhotoFavorite: $isCurrentPhotoFavorite,
              showCheckmark: $showCheckmark
            )
            .accessibilityIdentifier("apod-view-favorites-button")
          }
        }
      }
    }
    .onAppear {
      favoritesViewModel.loadFavorites()
      checkIfFavorite()
    }
  }

  func checkIfFavorite() {
    isCurrentPhotoFavorite = favoritesViewModel.isFavorite(photo)
  }
}
