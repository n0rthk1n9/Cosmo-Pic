//
//  DynamicPhotoView.swift
//  CosmoPic
//
//  Created by Jan Armbrust on 01.12.23.
//

import SwiftUI

struct DynamicPhotoView: View {
  let photo: Photo
  var showAsHeroImage: Bool? = false
  var size: CGSize? = .init(width: 100, height: 100)

  var body: some View {
    if let localFilename = photo.localFilename {
      let localFileURL = FileManager.localFileURL(for: localFilename)
      PhotoView(url: localFileURL, showAsHeroImage: showAsHeroImage, size: size)
    } else if let hdUrl = photo.hdURL {
      PhotoView(url: hdUrl, showAsHeroImage: showAsHeroImage, size: size)
    }
  }
}
