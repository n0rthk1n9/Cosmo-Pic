//
//  TodayPhotoView.swift
//  CosmoPic
//
//  Created by Jan Armbrust on 03.03.24.
//

import SwiftUI

struct TodayPhotoView: View {
  let photo: Photo
  let isDescriptionShowing: Bool
  let onInfoButtonTapped: () -> Void

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
        TodayPhotoCardFrontView(
          photo: photo,
          photoURL: photoURL,
          height: geometry.size.height,
          width: geometry.size.width
        ) {
          withAnimation {
            onInfoButtonTapped()
          }
        }

        if isDescriptionShowing {
          TodayPhotoCardBackView(
            photoExplanation: photo.explanation,
            height: geometry.size.height,
            width: geometry.size.width
          ) {
            withAnimation {
              onInfoButtonTapped()
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
  TodayPhotoView(photo: .allProperties, isDescriptionShowing: true) {
    print("pressed")
  }
  .environmentObject(FavoritesViewModel())
}
