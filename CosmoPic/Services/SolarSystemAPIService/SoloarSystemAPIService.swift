//
//  SoloarSystemAPIService.swift
//  CosmoPic
//
//  Created by Jan Armbrust on 18.04.24.
//

import Foundation

struct SoloarSystemAPIService: SoloarSystemAPIServiceProtocol {
  var session: URLSession {
    let sessionConfiguration: URLSessionConfiguration
    sessionConfiguration = URLSessionConfiguration.default
    return URLSession(configuration: sessionConfiguration)
  }

  func fetchPlanets() async throws -> [TriviaItem] {
    var urlComponents = URLComponents()
    urlComponents.scheme = "https"
    urlComponents.host = "api.le-systeme-solaire.net"
    urlComponents.path = "/rest.php/bodies"
    urlComponents.percentEncodedQueryItems = [
      URLQueryItem(name: "data", value: "englishName"),
      URLQueryItem(name: "filter%5B%5D", value: "isPlanet%2Ceq%2Ctrue")
    ]

    guard let url = urlComponents.url else {
      throw CosmoPicError.invalidURL
    }

    print(url)

    let request = URLRequest(url: url)

    do {
      let (data, response) = try await session.data(for: request)
      guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
        throw CosmoPicError.invalidResponseCode
      }

      let triviaItems = try JSONDecoder().decodeLogging(TriviaItems.self, from: data)
      let planets = triviaItems.bodies

      return planets
    } catch {
      throw error
    }
  }
}
