//
//  WelcomeView.swift
//  CosmoPic
//
//  Created by Jan Armbrust on 29.11.23.
//

import SwiftUI

struct WelcomeView: View {
  @Binding var isPresented: Bool

  var body: some View {
    VStack {
      Spacer()
      Text("Welcome to Cosmo Pic")
        .font(.largeTitle)
        .fontWeight(.bold)
        .padding(.horizontal, 15)
      Spacer()
      VStack(alignment: .leading, spacing: 36) {
        FeatureView(
          iconName: "photo.stack",
          featureTitle: "Astronomy Picture of the Day",
          featureText: "Discover breathtaking space imagery and learn about the cosmos."
        )
        FeatureView(
          iconName: "list.star",
          featureTitle: "Favorites",
          featureText: "Save your favorite cosmic images to view anytime."
        )
        FeatureView(
          iconName: "clock.arrow.circlepath",
          featureTitle: "1-Month History",
          featureText: "Explore a visual history of the last 30 days of astronomy pictures."
        )
      }
      .padding(.horizontal, 20)

      Spacer()

      Button(action: {
        isPresented = false
      }, label: {
        Text("Get Started")
          .frame(maxWidth: .infinity)
          .frame(height: 30)
          .contentShape(Rectangle())
      })
      .buttonStyle(.borderedProminent)
      .padding(.horizontal)
      .padding(.bottom)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color(.systemBackground))
  }
}
