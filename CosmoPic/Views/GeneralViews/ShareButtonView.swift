//
//  ShareButtonView.swift
//  CosmoPic
//
//  Created by Jan Armbrust on 03.03.24.
//

import SwiftUI

struct ShareButtonView: View {
  let photoURL: URL

  var body: some View {
    ShareLink(item: photoURL) {
      Image(systemName: "square.and.arrow.up")
        .font(.title)
        .foregroundColor(.white)
        .frame(width: 32, height: 32)
        .padding()
    }
    .background(.ultraThinMaterial)
    .clipShape(Circle())
    .padding(.horizontal)
  }
}

#Preview {
  let photoURL = URL(
    string: "https://upload.wikimedia.org/wikipedia/commons/thumb/f/fa/Apple_logo_black.svg/1920px-Apple_logo_black.svg.png"
  )
  if let photoURL {
    return ShareButtonView(
      photoURL: photoURL
    )
  }

  return Text("No url to share")
}
