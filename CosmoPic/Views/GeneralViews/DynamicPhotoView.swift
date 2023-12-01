//
//  DynamicPhotoView.swift
//  CosmoPic
//
//  Created by Jan Armbrust on 01.12.23.
//

import SwiftUI

struct DynamicPhotoView: View {
  let photo: Photo

  var body: some View {
    if let localFilename = photo.localFilename {
      let localFileURL = FileManager.localFileURL(for: localFilename)
      PhotoView(url: localFileURL)
    } else if let hdUrl = photo.hdURL {
      PhotoView(url: hdUrl)
    }
  }
}
