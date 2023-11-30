//
//  PhotoView.swift
//  CosmoPic
//
//  Created by Jan Armbrust on 28.11.23.
//

import SwiftUI

struct PhotoView: View {
  let url: URL

  var body: some View {
    AsyncImage(url: url) { image in
      image
        .resizable()
        .aspectRatio(contentMode: .fit)
    } placeholder: {
      ProgressView()
    }
    .cornerRadius(20)
    .clipped()
    .padding(.horizontal)
  }
}
