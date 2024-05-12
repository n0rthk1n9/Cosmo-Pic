//
//  TodayPhotoView.swift
//  CosmoPic
//
//  Created by Jan Armbrust on 03.03.24.
//

import SwiftUI

struct TodayPhotoView: View {
  let photo: Photo
  var onInfoButtonTapped: () -> Void

  var photoURL: URL? {
    if let localFilename = photo.localFilename {
      return FileManager.localFileURL(for: localFilename)
    } else if let hdUrl = photo.hdURL {
      return hdUrl
    } else {
      return nil
    }
  }

  var body: some View {
    VStack(alignment: .center) {
      GeometryReader { geometry in
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
              .frame(width: geometry.size.width, height: geometry.size.height)
              .cornerRadius(20)
              .clipped()

              InformationButtonView(photo: photo) {
                onInfoButtonTapped()
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

      Text(photo.title)
        .padding([.top, .trailing, .leading])
        .font(.title2)
    }
    .padding(20)
  }
}

#Preview {
  TodayPhotoView(photo: .allProperties) {
    print("pressed")
  }
  .environmentObject(FavoritesViewModel())
}
