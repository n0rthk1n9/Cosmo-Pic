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
  let mass: Mass
  let vol: Vol
  let semimajorAxis: Double
  let perihelion: Double
  let aphelion: Double
  let sideralOrbit: Double
  let sideralRotation: Double

  enum CodingKeys: String, CodingKey {
    case englishName, discoveredBy, discoveryDate, mass, vol, semimajorAxis, perihelion, aphelion, sideralOrbit,
         sideralRotation
  }
}

extension TriviaItem {
  static func fixture(
    englishName: String = "Earth",
    discoveredBy: String = "Hans Müller",
    discoveryDate: String = "09/04/1992",
    mass: Mass = Mass.fixture(),
    vol: Vol = Vol.fixture(),
    semimajorAxis: Double = 149.6e6,
    perihelion: Double = 147.1e6,
    aphelion: Double = 152.1e6,
    sideralOrbit: Double = 365.25,
    sideralRotation: Double = 24
  ) -> TriviaItem {
    TriviaItem(
      englishName: englishName,
      discoveredBy: discoveredBy,
      discoveryDate: discoveryDate,
      mass: mass,
      vol: vol,
      semimajorAxis: semimajorAxis,
      perihelion: perihelion,
      aphelion: aphelion,
      sideralOrbit: sideralOrbit,
      sideralRotation: sideralRotation
    )
  }

  static var allProperties: TriviaItem {
    .fixture(
      englishName: "Earth",
      discoveredBy: "Hans Müller",
      discoveryDate: "09/04/1992",
      mass: Mass.allProperties,
      vol: Vol.allProperties,
      semimajorAxis: 149.6e6,
      perihelion: 147.1e6,
      aphelion: 152.1e6,
      sideralOrbit: 365.25,
      sideralRotation: 24
    )
  }
}
