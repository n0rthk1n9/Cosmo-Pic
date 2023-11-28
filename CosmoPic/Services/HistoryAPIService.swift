//
//  HistoryAPIService.swift
//  CosmoPic
//
//  Created by Jan Armbrust on 28.11.23.
//

import Foundation

struct HistoryAPIService: HistoryAPIServiceProtocol {
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

  var session: URLSession {
    let sessionConfiguration: URLSessionConfiguration
    sessionConfiguration = URLSessionConfiguration.default
    return URLSession(configuration: sessionConfiguration)
  }

  func fetchHistory(starting startDate: String, ending endDate: String) async throws -> [Photo] {
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

  func saveHistory(_ history: [Photo], for date: String) throws {
    let historyFileName = "\(date)-history.json"
    let historyFilePath = FileManager.documentsDirectoryURL.appendingPathComponent(historyFileName)
    let encoder = JSONEncoder()
    encoder.outputFormatting = .prettyPrinted
    let jsonData = try encoder.encode(history)
    try jsonData.write(to: historyFilePath)
  }

  func loadHistory(for date: String) throws -> [Photo] {
    let historyFileName = "\(date)-history.json"
    let historyFilePath = FileManager.documentsDirectoryURL.appendingPathComponent(historyFileName)
    let jsonData = try Data(contentsOf: historyFilePath)
    return try JSONDecoder().decode([Photo].self, from: jsonData)
  }

  func updatePhotosWithLocalURLs(_ photos: [Photo], dateFormatter: DateFormatter) async throws -> [Photo] {
    return try await withThrowingTaskGroup(of: Photo?.self, returning: [Photo].self) { group in
      for photo in photos {
        group.addTask {
          guard photo.mediaType == "image" else { return nil }
          return try await self.updatePhotoWithLocalURL(photo, dateFormatter: dateFormatter)
        }
      }
      return try await group.compactMap { $0 }.reduce(into: []) { $0.append($1) }
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
}
