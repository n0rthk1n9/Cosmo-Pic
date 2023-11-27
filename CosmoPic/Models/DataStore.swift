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

  func getPhoto(for date: String) async throws {
    let fileManager = FileManager.default
    let apodJsonPathURL = URL(filePath: "\(date).json", relativeTo: FileManager.documentsDirectoryURL)

    if fileManager.fileExists(atPath: apodJsonPathURL.path) {
      Task { @MainActor in
        photo = try loadPhoto(from: apodJsonPathURL, for: date)
      }

      return
    }

    let fetchedPhoto = try await fetchAndSavePhoto(
      for: date,
      to: FileManager.documentsDirectoryURL,
      jsonPath: apodJsonPathURL
    )

    let jsonData = try JSONEncoder().encode(fetchedPhoto)
    try jsonData.write(to: apodJsonPathURL)

    Task { @MainActor in
      self.photo = fetchedPhoto
    }
  }

  private func fetchAndSavePhoto(for date: String, to directory: URL, jsonPath _: URL) async throws -> Photo {
    var urlComponents = URLComponents()
    urlComponents.scheme = "https"
    urlComponents.host = "api.nasa.gov"
    urlComponents.path = "/planetary/apod"
    urlComponents.queryItems = [
      URLQueryItem(name: "api_key", value: apiKey),
      URLQueryItem(name: "date", value: date)
    ]

    guard let url = urlComponents.url else {
      throw FetchPhotoError.invalidURL
    }

    let request = URLRequest(url: url)

    do {
      let (data, response) = try await session.data(for: request)
      guard (response as? HTTPURLResponse) != nil else {
        throw FetchPhotoError.invalidResponse
      }
      var decodedPhoto = try JSONDecoder().decode(Photo.self, from: data)

      let fileExtension = decodedPhoto.hdURL.pathExtension
      let localImagePath = directory.appendingPathComponent("\(date).\(fileExtension)")

      if let imageData = try? Data(contentsOf: decodedPhoto.hdURL) {
        try imageData.write(to: localImagePath)
      } else {
        throw FetchPhotoError.fileError
      }

      decodedPhoto.hdURL = localImagePath

      return decodedPhoto
    } catch let DecodingError.dataCorrupted(context) {
      print(context)
      throw DecodingError.dataCorrupted(context)
    } catch let DecodingError.keyNotFound(key, context) {
      print("Key '\(key)' not found:", context.debugDescription)
      print("codingPath:", context.codingPath)
      throw DecodingError.keyNotFound(key, context)
    } catch let DecodingError.valueNotFound(value, context) {
      print("Value '\(value)' not found:", context.debugDescription)
      print("codingPath:", context.codingPath)
      throw DecodingError.valueNotFound(value, context)
    } catch let DecodingError.typeMismatch(type, context) {
      print("Type '\(type)' mismatch:", context.debugDescription)
      print("codingPath:", context.codingPath)
      throw DecodingError.typeMismatch(type, context)
    } catch {
      print("error: ", error)
      throw error
    }
  }

  private func loadPhoto(from jsonPath: URL, for date: String) throws -> Photo {
    let fileManager = FileManager.default
    let documentsDirectory = jsonPath.deletingLastPathComponent()

    let possibleFiles = try fileManager.contentsOfDirectory(at: documentsDirectory, includingPropertiesForKeys: nil)
    guard let imagePath = possibleFiles
      .first(where: { $0.lastPathComponent.starts(with: date) && $0.pathExtension != "json" })
    else {
      throw FetchPhotoError.noFileFound
    }

    let jsonData = try Data(contentsOf: jsonPath)
    var photo = try JSONDecoder().decode(Photo.self, from: jsonData)
    photo.hdURL = imagePath
    return photo
  }
}
