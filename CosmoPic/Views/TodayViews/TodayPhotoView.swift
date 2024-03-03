//
//  TodayPhotoView.swift
//  CosmoPic
//
//  Created by Jan Armbrust on 03.03.24.
//

import SwiftUI

struct TodayPhotoView: View {
  let photo: Photo

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

          FavoriteButtonView(photo: photo)
        }
      }
      .padding(.horizontal, 20)

      Text(photo.title)
        .padding([.top, .trailing, .leading])
        .font(.title2)
    }
  }
}

#Preview {
  TodayPhotoView(photo: .allProperties)
    .environmentObject(FavoritesViewModel())
}
