//
//  TriviaItem.swift
//  CosmoPic
//
//  Created by Jan Armbrust on 18.04.24.
//

import Foundation

struct TriviaItem: Codable, Equatable, Hashable {
  let englishName: String
  let discoveredBy: String
  let discoveryDate: String

  enum CodingKeys: String, CodingKey {
    case englishName, discoveredBy, discoveryDate
  }
}

extension TriviaItem {
  static func fixture(
    englishName: String = "Earth",
    discoveredBy: String = "Hans Müller",
    discoveryDate: String = "09/04/1992"
  ) -> TriviaItem {
    TriviaItem(
      englishName: englishName,
      discoveredBy: discoveredBy,
      discoveryDate: discoveryDate
    )
  }

  static var allProperties: TriviaItem {
    .fixture(
      englishName: "Earth",
      discoveredBy: "Hans Müller",
      discoveryDate: "09/04/1992"
    )
  }
}
