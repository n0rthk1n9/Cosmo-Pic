//
//  HistoryAPIService.swift
//  CosmoPic
//
//  Created by Jan Armbrust on 28.11.23.
//

import Foundation
import UIKit

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
        throw FetchHistoryError.invalidResponseCode
      }

      let photos = try JSONDecoder().decode([Photo].self, from: data)
      return photos
    } catch {
      try JSONDecoderErrorHandler().handleError(error: error)
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
    do {
      let historyFileName = "\(date)-history.json"
      let historyFilePath = FileManager.documentsDirectoryURL.appendingPathComponent(historyFileName)
      let jsonData = try Data(contentsOf: historyFilePath)
      return try JSONDecoder().decode([Photo].self, from: jsonData)
    } catch {
      try JSONDecoderErrorHandler().handleError(error: error)
      throw error
    }
  }

  func updatePhotosWithLocalURLs(
    _ photos: [Photo],
    dateFormatter: DateFormatter,
    onPhotoUpdated: @escaping () -> Void
  ) async throws -> [Photo] {
    var updatedPhotos: [Photo] = []
    try await withThrowingTaskGroup(of: Photo?.self) { group in
      for photo in photos {
        group.addTask {
          guard photo.mediaType == "image" else { return nil }
          let updatedPhoto = try await self.updatePhotoWithLocalURL(photo, dateFormatter: dateFormatter)
          return updatedPhoto
        }
      }
      for try await updatedPhotoOptional in group {
        if let updatedPhoto = updatedPhotoOptional {
          onPhotoUpdated()
          updatedPhotos.append(updatedPhoto)
        }
      }
    }
    return updatedPhotos
  }

  func updatePhotoWithLocalURL(_ photo: Photo, dateFormatter _: DateFormatter) async throws -> Photo {
    var updatedPhoto = photo
    let identifier = photo.date
    guard let photoHdURL = photo.hdURL else {
      throw FetchHistoryError.invalidURL
    }
    if let (fullSizeFilename, thumbnailFilename) = try? await cacheImageAndCreateThumbnail(
      from: photoHdURL,
      identifier: photo.date
    ) {
      updatedPhoto.localFilename = fullSizeFilename
      updatedPhoto.localFilenameThumbnail = thumbnailFilename
    }
    return updatedPhoto
  }

  func cacheImageAndCreateThumbnail(from url: URL,
                                    identifier: String) async throws -> (
    fullSizeFilename: String,
    thumbnailFilename: String
  ) {
    let fileExtension = url.pathExtension
    let fullSizeFilename = "\(identifier).\(fileExtension)"
    let thumbnailFilename = "\(identifier)-thumbnail.\(fileExtension)"

    let fullSizeFileURL = FileManager.documentsDirectoryURL.appendingPathComponent(fullSizeFilename)
    let thumbnailFileURL = FileManager.documentsDirectoryURL.appendingPathComponent(thumbnailFilename)

    // Check if the full-size file already exists
    if FileManager.default.fileExists(atPath: fullSizeFileURL.path) && FileManager.default
      .fileExists(atPath: thumbnailFileURL.path)
    {
      // Assume the thumbnail also exists if the full-size image does, and return both filenames
      return (fullSizeFilename, thumbnailFilename)
    } else {
      // Download the image
      let (imageData, _) = try await URLSession.shared.data(from: url)
      try imageData.write(to: fullSizeFileURL)

      // Create and save the thumbnail
      if let image = UIImage(data: imageData) {
        // Ensure we're on the main actor before processing the image
        await MainActor.run {
          if let thumbnailData = image.downsampledData(
            to: CGSize(width: 100, height: 100),
            scale: UIScreen.main.scale
          ) {
            do {
              try thumbnailData.write(to: thumbnailFileURL)
            } catch {
              print("Failed to write thumbnail data: \(error)")
            }
          }
        }
      }

      return (fullSizeFilename, thumbnailFilename)
    }
  }
}
