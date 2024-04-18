//
//  SoloarSystemAPIService.swift
//  CosmoPic
//
//  Created by Jan Armbrust on 18.04.24.
//

import Foundation

struct SoloarSystemAPIService: SoloarSystemAPIServiceProtocol {
  func fetchPlanets() async throws -> [TriviaItem] {
    return [TriviaItem(englishName: "Earth")]
  }
}
