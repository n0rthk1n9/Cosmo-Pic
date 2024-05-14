//
//  TodayPhotoCardFrontView.swift
//  CosmoPic
//
//  Created by Jan Armbrust on 14.05.24.
//

import SwiftUI

struct TodayPhotoCardFrontView: View {
  let photo: Photo
  let photoURL: URL?
  let height: CGFloat
  let width: CGFloat
  let onInfoButtonTapped: () -> Void

  var body: some View {
    ZStack(alignment: .topTrailing) {
      ZStack(alignment: .bottomTrailing) {
        ZStack(alignment: .bottomLeading) {
          AsyncImage(url: photoURL) { image in
            image
              .resizable()
              .aspectRatio(contentMode: .fill)
          } placeholder: {
            HStack {
              Spacer()
              ProgressView()
                .frame(height: 300)
              Spacer()
            }
          }
          .frame(width: width, height: height)
          .cornerRadius(20)
          .clipped()

          InformationButtonView(photo: photo) {
            withAnimation {
              onInfoButtonTapped()
            }
          }
        }

        SaveButtonView(photoURL: photoURL)
      }

      VStack {
        FavoriteButtonView(photo: photo)
        if let photoURL {
          ShareButtonView(photoURL: photoURL)
        }
      }
    }
  }
}

#Preview {
  TodayPhotoCardFrontView(
    photo: .allProperties,
    photoURL: nil,
    height: 300,
    width: 100
  ) {
    print("pressed")
  }
}
