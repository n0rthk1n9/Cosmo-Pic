//
//  SoloarSystemAPIServiceProtocoll.swift
//  CosmoPic
//
//  Created by Jan Armbrust on 18.04.24.
//

import Foundation

protocol SoloarSystemAPIServiceProtocol {
  func fetchPlanets() async throws -> [TriviaItem]
  func savePlanets(_ planets: TriviaItems) throws
  func loadPlanets() throws -> [TriviaItem]
}
