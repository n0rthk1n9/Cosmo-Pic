//
//  PhotoView.swift
//  CosmoPic
//
//  Created by Jan Armbrust on 28.11.23.
//

import SwiftUI

struct PhotoView: View {
  let url: URL
  var showAsHeroImage: Bool? = false
  var size: CGSize? = .init(width: 100, height: 100)

  var body: some View {
    if let showAsHeroImage, let size {
      if showAsHeroImage {
        AsyncImage(
          url: url,
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
      } else {
        AsyncImage(url: url) { image in
          image
            .resizable()
            .aspectRatio(contentMode: .fit)
        } placeholder: {
          HStack {
            Spacer()
            ProgressView()
              .frame(height: 300)
            Spacer()
          }
        }
        .cornerRadius(20)
        .clipped()
        .padding(.horizontal)
      }
    }
  }
}

#Preview {
  guard let url =
    URL(
      string: "https://upload.wikimedia.org/wikipedia/commons/thumb/f/fa/Apple_logo_black.svg/1024px-Apple_logo_black.svg.png"
    )
  else {
    return Text("Error creating url")
  }

  return PhotoView(url: url, showAsHeroImage: true)
}
