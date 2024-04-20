//
//  TriviaViewModel.swift
//  CosmoPic
//
//  Created by Jan Armbrust on 18.04.24.
//

import Foundation

@Observable
class TriviaViewModel {
  var planets: [TriviaItem] = []
  var isLoading = false

  var error: CosmoPicError?

  @ObservationIgnored private let soloarSystemAPIService: SolarSystemAPIServiceProtocol

  init(soloarSystemAPIService: SolarSystemAPIServiceProtocol = SolarSystemAPIService()) {
    self.soloarSystemAPIService = soloarSystemAPIService
  }

  @MainActor
  func getPlanets() async {
    isLoading = true

    let planetsFilePath = FileManager.appGroupContainerURL.appendingPathComponent("planets.json")

    do {
      if FileManager.default.fileExists(atPath: planetsFilePath.path) {
        planets = try soloarSystemAPIService.loadPlanets()
        print("loaded from file")
      } else {
        let fetchedPlanets = try await soloarSystemAPIService.fetchPlanets()

        try soloarSystemAPIService.savePlanets(TriviaItems(bodies: fetchedPlanets))

        planets = fetchedPlanets
        print("loaded from web")
      }
    } catch let error as CosmoPicError {
      self.error = error
    } catch {
      self.error = .other(error: error)
    }
    isLoading = false
  }
}
