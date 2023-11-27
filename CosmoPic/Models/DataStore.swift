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

      guard let decodedPhotoHdUrl = decodedPhoto.hdURL else {
        throw FetchPhotoError.fileError
      }

      let fileExtension = decodedPhotoHdUrl.pathExtension
      let localImagePath = directory.appendingPathComponent("\(date).\(fileExtension)")

      if let imageData = try? Data(contentsOf: decodedPhotoHdUrl) {
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
    let oneMonthAgo = Calendar.current.date(byAdding: .month, value: -1, to: currentDate)!

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

        let newJsonData = try JSONEncoder().encode(fetchedHistory)
        try newJsonData.write(to: historyFilePath)

        Task { @MainActor in
          self.history = fetchedHistory
        }
      }
    } catch {
      throw error
    }
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
}
