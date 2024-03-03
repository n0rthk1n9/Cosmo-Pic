//
//  DynamicPhotoView.swift
//  CosmoPic
//
//  Created by Jan Armbrust on 01.12.23.
//

import SwiftUI

struct DynamicPhotoView: View {
  let photo: Photo
  var size: CGSize? = .init(width: 100, height: 100)

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
    if let size {
      ZStack(alignment: .topTrailing) {
        ZStack(alignment: .bottomTrailing) {
          AsyncImage(
            url: photoURL,
            content: { image in
              image
                .resizable()
            },
            placeholder: {
              ProgressView()
            }
          )
          .scaledToFill()
          .ignoresSafeArea()
          .frame(maxWidth: size.width, maxHeight: size.height * 0.60)

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
}

#Preview {
  DynamicPhotoView(photo: .allProperties)
    .environmentObject(FavoritesViewModel())
}
