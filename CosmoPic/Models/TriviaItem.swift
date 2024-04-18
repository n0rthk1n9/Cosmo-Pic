//
//  TriviaItem.swift
//  CosmoPic
//
//  Created by Jan Armbrust on 18.04.24.
//

import Foundation

struct TriviaItem: Codable, Equatable, Hashable {
  let englishName: String

  enum CodingKeys: String, CodingKey {
    case englishName
  }
}

extension TriviaItem {
  static func fixture(
    englishName: String = "Earth"
  ) -> TriviaItem {
    TriviaItem(
      englishName: englishName
    )
  }

  static var allProperties: TriviaItem {
    .fixture(
      englishName: "Earth"
    )
  }
}
