//
//  PlanetRowView.swift
//  CosmoPic
//
//  Created by Jan Armbrust on 20.04.24.
//

import SwiftUI

struct PlanetRowView: View {
  let planet: TriviaItem

  var body: some View {
    HStack(alignment: .top, spacing: 10) {
      Image(planet.englishName.lowercased())
        .resizable()
        .frame(width: 100, height: 100)
        .clipShape(RoundedRectangle(cornerRadius: 5))
      VStack(alignment: .leading, spacing: 5) {
        Text(planet.englishName)

        Text(planet.englishName)
          .font(.caption)
      }
      .padding(.trailing, 10)
      .padding(.vertical, 5)
    }
  }
}

#Preview {
  PlanetRowView(planet: TriviaItem.allProperties)
}
