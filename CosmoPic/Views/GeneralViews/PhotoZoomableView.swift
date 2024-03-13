//
//  PhotoZoomableView.swift
//  CosmoPic
//
//  Created by Jan Armbrust on 13.03.24.
//

import SwiftUI

struct PhotoZoomableView: View {
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

  @GestureState private var zoom = 1.0

  var body: some View {
    PhotoZoomableContainerView {
      AsyncImage(url: photoURL) { state in
        if let image = state.image {
          image
            .resizable()
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .scaledToFit()
            .padding(.horizontal, 8)
            .scaleEffect(zoom)
        }
      }
    }
  }
}

#Preview {
  PhotoZoomableView(photo: .allProperties)
}
