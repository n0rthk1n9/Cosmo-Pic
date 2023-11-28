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
  @Published var history: [Photo] = []
  @Published var favorites: [Photo] = []

  private var apiKey: String {
    if let filePath = Bundle.main.path(forResource: "APOD-Info", ofType: "plist") {
      let plist = NSDictionary(contentsOfFile: filePath)
      guard let value = plist?.object(forKey: "API_KEY") as? String else {
        fatalError("Couldn't find key 'API_KEY' in 'APOD-Info.plist'.")
      }
      return value
    } else {
      guard let sampleFilePath = Bundle.main.path(forResource: "APOD-Info-Sample", ofType: "plist") else {
        fatalError("Couldn't find either file 'APOD-Info-Sample.plist'.")
      }
      let plist = NSDictionary(contentsOfFile: sampleFilePath)
      guard let value = plist?.object(forKey: "API_KEY") as? String else {
        fatalError("Couldn't find key 'API_KEY' in 'APOD-Info-Sample.plist'.")
      }
      print("Using demo key, register your own key at: https://api.nasa.gov/")
      return value
    }
  }

  private let session: URLSession
  private let sessionConfiguration: URLSessionConfiguration
  private let favoritesFileName = "favorites.json"

  init() {
    sessionConfiguration = URLSessionConfiguration.default
    session = URLSession(configuration: sessionConfiguration)
  }

  func getPhoto(for date: String) async throws {
    Task { @MainActor in
      photo = nil
    }

    let fileManager = FileManager.default
    let apodJsonPathURL = URL(filePath: "\(date).json", relativeTo: FileManager.documentsDirectoryURL)

    if fileManager.fileExists(atPath: apodJsonPathURL.path) {
      Task { @MainActor in
        photo = try loadPhoto(from: apodJsonPathURL, for: date)
      }

      return
    }

    let fetchedPhoto = try await fetchAndSavePhoto(for: date, to: FileManager.documentsDirectoryURL)

    let encoder = JSONEncoder()
    encoder.outputFormatting = .prettyPrinted

    let jsonData = try encoder.encode(fetchedPhoto)
    try jsonData.write(to: apodJsonPathURL)

    Task { @MainActor in
      self.photo = fetchedPhoto
    }
  }

  private func fetchAndSavePhoto(for date: String, to directory: URL) async throws -> Photo {
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
      guard let httpResponse = response as? HTTPURLResponse else {
        throw FetchPhotoError.invalidResponse
      }

      if httpResponse.statusCode == 404 {
        let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        if json?["msg"] as? String == "No data available for date: \(date)" {
          throw FetchPhotoError.invalidResponse
        }
      }
      var decodedPhoto = try JSONDecoder().decode(Photo.self, from: data)

      guard decodedPhoto.mediaType == "image", let decodedPhotoHdUrl = decodedPhoto.hdURL else {
        throw FetchPhotoError.fileError
      }

      let fileExtension = decodedPhotoHdUrl.pathExtension
      let localFilename = "\(date).\(fileExtension)"
      let localImagePath = directory.appendingPathComponent(localFilename)

      if !FileManager.default.fileExists(atPath: localImagePath.path) {
        let (imageData, _) = try await session.data(from: decodedPhotoHdUrl)
        try imageData.write(to: localImagePath)
      }

      decodedPhoto.localFilename = localFilename

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

    let possibleFiles = try fileManager.contentsOfDirectory(
      at: FileManager.documentsDirectoryURL,
      includingPropertiesForKeys: nil
    )
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

  func fetchHistory() async throws {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"

    let currentDate = Date()
    guard let oneMonthAgo = Calendar.current.date(byAdding: .month, value: -1, to: currentDate) else {
      throw FetchPhotoError.fileError
    }

    let todayString = dateFormatter.string(from: currentDate)
    let startDate = dateFormatter.string(from: oneMonthAgo)

    let fileManager = FileManager.default
    let historyFileName = "\(todayString)-history.json"
    let historyFilePath = FileManager.documentsDirectoryURL.appendingPathComponent(historyFileName)

    do {
      if fileManager.fileExists(atPath: historyFilePath.path) {
        let jsonData = try Data(contentsOf: historyFilePath)
        let loadedHistory = try JSONDecoder().decode([Photo].self, from: jsonData)
        Task { @MainActor in
          self.history = loadedHistory
        }
      } else {
        let existingHistoryFiles = try fileManager.contentsOfDirectory(
          at: FileManager.documentsDirectoryURL,
          includingPropertiesForKeys: nil
        )

        for file in existingHistoryFiles where file.lastPathComponent.contains("-history.json") {
          try fileManager.removeItem(at: file)
        }

        let fetchedHistory = try await fetchPhotosFromAPI(starting: startDate, ending: todayString)

        let updatedHistory = try await withThrowingTaskGroup(of: Photo?.self, returning: [Photo].self) { group in
          for photo in fetchedHistory {
            group.addTask {
              guard photo.mediaType == "image" else { return nil }
              return try await self.updatePhotoWithLocalURL(photo, dateFormatter: dateFormatter)
            }
          }

          return try await group.compactMap { $0 }.reduce(into: []) { $0.append($1) }
        }

        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted

        let newJsonData = try encoder.encode(updatedHistory)
        try newJsonData.write(to: historyFilePath)

        Task { @MainActor in
          self.history = updatedHistory
        }
      }
    } catch {
      throw error
    }
  }

  func updatePhotoWithLocalURL(_ photo: Photo, dateFormatter _: DateFormatter) async throws -> Photo {
    var updatedPhoto = photo
    let identifier = photo.date
    guard let photoHdURL = photo.hdURL else {
      throw FetchPhotoError.invalidURL
    }
    if let localFilename = try? await cacheImage(from: photoHdURL, identifier: identifier) {
      updatedPhoto.localFilename = localFilename
    }
    return updatedPhoto
  }

  func cacheImage(from url: URL, identifier: String) async throws -> String {
    let fileExtension = url.pathExtension
    let filename = "\(identifier).\(fileExtension)"
    let localFileURL = FileManager.documentsDirectoryURL.appendingPathComponent(filename)

    let (imageData, _) = try await URLSession.shared.data(from: url)
    try imageData.write(to: localFileURL)

    return filename
  }

  private func fetchPhotosFromAPI(starting startDate: String, ending endDate: String) async throws -> [Photo] {
    var urlComponents = URLComponents()
    urlComponents.scheme = "https"
    urlComponents.host = "api.nasa.gov"
    urlComponents.path = "/planetary/apod"
    urlComponents.queryItems = [
      URLQueryItem(name: "api_key", value: apiKey),
      URLQueryItem(name: "start_date", value: startDate),
      URLQueryItem(name: "end_date", value: endDate)
    ]

    guard let url = urlComponents.url else {
      throw FetchPhotoError.invalidURL
    }

    let request = URLRequest(url: url)

    do {
      let (data, response) = try await session.data(for: request)
      guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
        throw FetchPhotoError.invalidResponse
      }

      let photos = try JSONDecoder().decode([Photo].self, from: data)
      return photos
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

  func loadFavorites() {
    let fileManager = FileManager.default
    let favoritesFileURL = FileManager.documentsDirectoryURL.appendingPathComponent(favoritesFileName)

    if fileManager.fileExists(atPath: favoritesFileURL.path) {
      do {
        let jsonData = try Data(contentsOf: favoritesFileURL)
        favorites = try JSONDecoder().decode([Photo].self, from: jsonData)
      } catch {
        print("Error loading favorites: \(error.localizedDescription)")
      }
    }
  }

  func addToFavorites(_ photo: Photo) {
    if !favorites.contains(where: { $0.title == photo.title }) {
      favorites.append(photo)
      saveFavorites()
    }
  }

  func removeFromFavorites(_ photo: Photo) {
    favorites.removeAll { $0.title == photo.title }
    saveFavorites()
  }

  private func saveFavorites() {
    let favoritesFileURL = FileManager.documentsDirectoryURL.appendingPathComponent(favoritesFileName)

    do {
      let jsonData = try JSONEncoder().encode(favorites)
      try jsonData.write(to: favoritesFileURL)
    } catch {
      print("Error saving favorites: \(error.localizedDescription)")
    }
  }

  func isFavorite(_ photo: Photo) -> Bool {
    return favorites.contains { $0.title == photo.title }
  }
}
