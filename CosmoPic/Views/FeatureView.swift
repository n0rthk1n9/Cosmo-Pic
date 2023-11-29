//
//  FeatureView.swift
//  CosmoPic
//
//  Created by Jan Armbrust on 29.11.23.
//

import SwiftUI

struct FeatureView: View {
  let iconName: String
  let featureTitle: String
  let featureText: String

  var body: some View {
    HStack {
      Image(systemName: iconName)
        .foregroundColor(.blue)
        .font(.system(size: 30))
        .padding(.trailing)
      VStack(alignment: .leading) {
        Text(featureTitle)
          .font(.headline)
        Text(featureText)
          .fixedSize(horizontal: false, vertical: true)
          .font(.subheadline)
          .foregroundStyle(.gray)
      }
    }
  }
}
