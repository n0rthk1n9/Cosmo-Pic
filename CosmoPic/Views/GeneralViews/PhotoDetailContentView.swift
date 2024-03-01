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
    GeometryReader { geometry in
      if fullDetail {
        VStack {
          ZStack {
            DynamicPhotoView(photo: photo, showAsHeroImage: true, size: geometry.size)
          }
          Form {
            Section {
              Text(photo.title)
                .font(.title)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)
            }

            if showCheckmark {
              CheckmarkView(showCheckmark: $showCheckmark)
                .frame(maxWidth: .infinity, alignment: .center)
            } else if !isCurrentPhotoFavorite {
              FavoriteButtonView(
                photo: photo,
                isCurrentPhotoFavorite: $isCurrentPhotoFavorite,
                showCheckmark: $showCheckmark
              )
              .frame(maxWidth: .infinity, alignment: .center)
            }
            Section {
              Text(
                photo.explanation
                  .replacingOccurrences(of: "  ", with: " ")
              )
              .font(.caption)
              .accessibilityIdentifier("photo-detail-view-photo-explanation")
            }
          }
          .padding(.top, -10)
        }
      } else {
        VStack(alignment: .center) {
          DynamicPhotoView(photo: photo)

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

#Preview {
  PhotoDetailContentView(photo: .allProperties, fullDetail: false)
    .environmentObject(FavoritesViewModel())
}
