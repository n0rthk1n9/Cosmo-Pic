//
//  PhotoDetailContentView.swift
//  CosmoPic
//
//  Created by Jan Armbrust on 10.02.24.
//

import SwiftUI

struct PhotoDetailContentView: View {
  @EnvironmentObject var favoritesViewModel: FavoritesViewModel

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
      }
    }

    .onAppear {
      favoritesViewModel.loadFavorites()
    }
  }
}

#Preview {
  PhotoDetailContentView(photo: .allProperties, fullDetail: false)
    .environmentObject(FavoritesViewModel())
}
