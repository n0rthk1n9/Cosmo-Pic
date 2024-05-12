//
//  InformationButtonView.swift
//  CosmoPic
//
//  Created by Jan Armbrust on 12.05.24.
//

import SwiftUI

struct InformationButtonView: View {
  let photo: Photo
  var onInfoButtonTapped: () -> Void

  var body: some View {
    Button(action: {
      let generator = UIImpactFeedbackGenerator(style: .medium)
      generator.impactOccurred()
      withAnimation {
        onInfoButtonTapped()
      }
    }, label: {
      Image(systemName: "info.circle")
        .font(.title)
        .foregroundStyle(.white)
        .frame(width: 32, height: 32)
        .padding()
    })
    .background(.ultraThinMaterial)
    .clipShape(Circle())
    .padding()
  }
}

#Preview {
  InformationButtonView(photo: .allProperties) {
    print("tapped")
  }
}
