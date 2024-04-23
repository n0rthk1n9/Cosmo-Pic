//
//  Mass.swift
//  CosmoPic
//
//  Created by Jan Armbrust on 23.04.24.
//

import Foundation

struct Mass: Codable, Equatable, Hashable {
  let massValue: Double
  let massExponent: Int
}

extension Mass {
  static func fixture(
    massValue: Double = 5.972,
    massExponent: Int = 10
  ) -> Mass {
    Mass(massValue: massValue, massExponent: massExponent)
  }

  static var allProperties: Mass {
    .fixture(massValue: 5.972, massExponent: 10)
  }
}
