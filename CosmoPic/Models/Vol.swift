//
//  Vol.swift
//  CosmoPic
//
//  Created by Jan Armbrust on 23.04.24.
//

import Foundation

struct Vol: Codable, Equatable, Hashable {
  let volValue: Double
  let volExponent: Int
}

extension Vol {
  static func fixture(
    volValue: Double = 5.972,
    volExponent: Int = 10
  ) -> Vol {
    Vol(volValue: volValue, volExponent: volExponent)
  }

  static var allProperties: Vol {
    .fixture(volValue: 5.972, volExponent: 10)
  }
}
