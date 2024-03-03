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

  var body: some View {
    if let localFilename = photo.localFilename {
      let localFileURL = FileManager.localFileURL(for: localFilename)
      PhotoView(photo: photo, url: localFileURL, size: size)
    } else if let hdUrl = photo.hdURL {
      PhotoView(photo: photo, url: hdUrl, size: size)
    }
  }
}

#Preview {
  DynamicPhotoView(photo: .allProperties)
    .environmentObject(FavoritesViewModel())
}
