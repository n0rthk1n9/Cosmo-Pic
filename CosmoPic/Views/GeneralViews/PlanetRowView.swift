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
        Text(planet.discoveredBy)
          .font(.caption)
        Text(getFormattedDiscoveryDate(planet.discoveryDate))
      }
      .padding(.trailing, 10)
      .padding(.vertical, 5)
    }
  }

  func getFormattedDiscoveryDate(_ date: String) -> String {
    let dateFormatter = DateFormatter()

    dateFormatter.dateFormat = "dd/MM/yyyy"
    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
    guard let safeDate = dateFormatter.date(from: date) else { return "Date not available" }

    dateFormatter.dateStyle = .long
    dateFormatter.timeStyle = .none
    dateFormatter.locale = Locale.current

    return dateFormatter.string(from: safeDate)
  }
}

#Preview {
  PlanetRowView(planet: TriviaItem.allProperties)
}
