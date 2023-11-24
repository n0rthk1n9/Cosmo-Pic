//
//  DataStore.swift
//  CosmoPic
//
//  Created by Jan Armbrust on 24.11.23.
//

import Foundation
import SwiftUI

class DataStore: ObservableObject {
  @Published var photo: Photo?

  private var apiKey = ""

  private let session: URLSession
  private let sessionConfiguration: URLSessionConfiguration

  init() {
    sessionConfiguration = URLSessionConfiguration.default
    session = URLSession(configuration: sessionConfiguration)
    apiKey = "DEMO_KEY"
  }

  func fetchPhoto(for date: String) async throws {
    var urlComponents = URLComponents()
    urlComponents.scheme = "https"
    urlComponents.host = "api.nasa.gov"
    urlComponents.path = "/planetary/apod"
    urlComponents.queryItems = [
      URLQueryItem(name: "api_key", value: apiKey),
      URLQueryItem(name: "date", value: date),
    ]

    guard let url = urlComponents.url else {
      throw FetchPhotoError.invalidURL
    }

    let request = URLRequest(url: url)

    do {
      let (data, response) = try await session.data(for: request)
      guard let httpResponse = response as? HTTPURLResponse else {
        throw FetchPhotoError.invalidResponse
      }
      let decodedAPODAPIPhotoResponse = try JSONDecoder().decode(Photo.self, from: data)
      Task { @MainActor in
        self.photo = decodedAPODAPIPhotoResponse
      }
    } catch is URLError {
      throw FetchPhotoError.requestFailed
    } catch is DecodingError {
      throw FetchPhotoError.decodingFailed
    }
  }
}
