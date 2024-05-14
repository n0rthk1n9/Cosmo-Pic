//
//  TodayPhotoCardBackView.swift
//  CosmoPic
//
//  Created by Jan Armbrust on 14.05.24.
//

import SwiftUI

struct TodayPhotoCardBackView: View {
  let photoExplanation: String
  let height: CGFloat
  let width: CGFloat
  let onInfoButtonTapped: () -> Void

  var body: some View {
    ScrollView {
      Text(photoExplanation)
    }
    .padding()
    .frame(width: width, height: height)
    .background(.ultraThinMaterial)
    .cornerRadius(20)
    .clipped()
    .onTapGesture {
      withAnimation {
        onInfoButtonTapped()
      }
    }
  }
}

#Preview {
  TodayPhotoCardBackView(photoExplanation: "Test", height: 300, width: 100) {
    print("pressed")
  }
}
