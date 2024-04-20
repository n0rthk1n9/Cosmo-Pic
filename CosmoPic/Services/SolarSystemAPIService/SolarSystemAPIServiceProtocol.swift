//
//  SolarSystemAPIServiceProtocoll.swift
//  CosmoPic
//
//  Created by Jan Armbrust on 18.04.24.
//

import Foundation

protocol SolarSystemAPIServiceProtocol {
  func fetchPlanets() async throws -> [TriviaItem]
  func savePlanets(_ planets: TriviaItems) throws
  func loadPlanets() throws -> [TriviaItem]
}
