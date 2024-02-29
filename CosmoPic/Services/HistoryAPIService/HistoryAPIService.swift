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
      throw CosmoPicError.invalidURL
    }

    let request = URLRequest(url: url)

    do {
      let (data, response) = try await session.data(for: request)
      guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
        throw CosmoPicError.invalidResponseCode
      }

      let photos = try JSONDecoder().decodeLogging([Photo].self, from: data)
      return photos
    } catch {
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
      return try JSONDecoder().decodeLogging([Photo].self, from: jsonData)
    } catch {
      throw error
    }
  }

  func updatePhotosWithLocalURLs(
    _ photos: [Photo],
    onPhotoUpdated: @escaping () -> Void
  ) async throws -> [Photo] {
    var updatedPhotos: [Photo] = []
    try await withThrowingTaskGroup(of: Photo?.self) { group in
      for photo in photos {
        group.addTask {
          guard photo.mediaType == "image" else { return nil }
          let updatedPhoto = try await self.updatePhotoWithLocalURL(photo)
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

  func updatePhotoWithLocalURL(_ photo: Photo) async throws -> Photo {
    var updatedPhoto = photo
    guard let photoSdURL = photo.sdURL else {
      throw CosmoPicError.invalidURL
    }
    if let thumbnailFilename = try? await cacheThumbnail(from: photoSdURL, identifier: photo.date) {
      updatedPhoto.localFilenameThumbnail = thumbnailFilename
    }
    return updatedPhoto
  }

  func cacheThumbnail(from url: URL, identifier: String) async throws -> String {
    let fileExtension = url.pathExtension
    let thumbnailFilename = "\(identifier)-thumbnail.\(fileExtension)"
    let thumbnailFileURL = FileManager.documentsDirectoryURL.appendingPathComponent(thumbnailFilename)

    // Check if the thumbnail file already exists
    if FileManager.default.fileExists(atPath: thumbnailFileURL.path) {
      // The thumbnail already exists, no need to re-download or recreate it
      return thumbnailFilename
    } else {
      // Download the image data
      let (imageData, _) = try await URLSession.shared.data(from: url)

      // Attempt to create and save the thumbnail
      if let image = UIImage(data: imageData) {
        await MainActor.run {
          #if !os(visionOS)
            let scale = UIScreen.main.scale
          #else
            let scale = 2.0
          #endif
          if let thumbnailData = image.downsampledData(
            to: CGSize(width: 100, height: 100),
            scale: scale
          ) {
            do {
              try thumbnailData.write(to: thumbnailFileURL)
            } catch {
              print("Failed to write thumbnail data: \(error)")
            }
          }
        }
      }
      return thumbnailFilename
    }
  }
}
