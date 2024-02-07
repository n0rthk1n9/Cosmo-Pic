//
//  HistoryRowView.swift
//  CosmoPic
//
//  Created by Jan Armbrust on 01.12.23.
//

import SwiftUI

struct HistoryRowView: View {
  let photo: Photo

  var body: some View {
    HStack(alignment: .top, spacing: 0.0) {
      photoImageView
      photoInfoView
    }
  }

  private var photoImageView: some View {
    Group {
      if let localFilenameThumbnail = photo.localFilenameThumbnail {
        AsyncImage(url: FileManager.localFileURL(for: localFilenameThumbnail), content: { image in
          image.resizable()
        }, placeholder: {
          ProgressView()
        })
      } else {
        AsyncImage(url: photo.hdURL, content: { image in
          image.resizable()
        }, placeholder: {
          ProgressView()
        })
      }
    }
    .aspectRatio(contentMode: .fit)
    .frame(height: 30)
    .frame(minWidth: 60)
    .padding(.trailing)
  }

  private var photoInfoView: some View {
    VStack(alignment: .leading, spacing: 0.0) {
      Text(photo.title)
      Text(photo.copyright ?? "No copyright")
        .font(.caption)
        .foregroundStyle(.gray)
        .padding(.top)
    }
  }
}
