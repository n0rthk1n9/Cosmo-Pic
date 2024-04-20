//
//  TriviaItems.swift
//  CosmoPic
//
//  Created by Jan Armbrust on 18.04.24.
//

import Foundation

struct TriviaItems: Codable, Equatable, Hashable {
  let bodies: [TriviaItem]

  enum CodingKeys: String, CodingKey {
    case bodies
  }
}

extension TriviaItems {
  static func fixture(
    bodies: [TriviaItem] = [
      TriviaItem(
        englishName: "Earth",
        discoveredBy: "Hans Müller",
        discoveryDate: "09/04/1992"
      )
    ]
  ) -> TriviaItems {
    TriviaItems(
      bodies: bodies
    )
  }

  static var allProperties: TriviaItems {
    .fixture(
      bodies: [
        TriviaItem(
          englishName: "Earth",
          discoveredBy: "Hans Müller",
          discoveryDate: "09/04/1992"
        )
      ]
    )
  }
}
