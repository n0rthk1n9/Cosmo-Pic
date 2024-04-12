//
//  PhotoAPIService.swift
//  CosmoPic
//
//  Created by Jan Armbrust on 28.11.23.
//

import Foundation
import UIKit

struct PhotoAPIService: PhotoAPIServiceProtocol {
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

  func fetchPhoto(from date: String, retryHandler: (() -> Void)?) async throws -> Photo {
    var urlComponents = URLComponents()
    urlComponents.scheme = "https"
    urlComponents.host = "api.nasa.gov"
    urlComponents.path = "/planetary/apod"
    urlComponents.queryItems = [
      URLQueryItem(name: "api_key", value: apiKey),
      URLQueryItem(name: "date", value: date)
    ]

    guard let url = urlComponents.url else {
      throw CosmoPicError.invalidURL
    }

    let request = URLRequest(url: url)

    do {
      let (data, response) = try await session.data(for: request)
      guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 404 {
          let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
          if json?["msg"] as? String == "No data available for date: \(date)" {
            throw CosmoPicError.photoForTodayNotAvailableYet(retryHandler: retryHandler)
          }
        } else if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 400 {
          let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
          let msg = json?["msg"] as? String
          if msg?.contains("Date must be between") != nil {
            throw CosmoPicError.photoForTodayNotAvailableYet(retryHandler: retryHandler)
          }
        }
        throw CosmoPicError.invalidResponseCode
      }

      let photo = try JSONDecoder().decodeLogging(Photo.self, from: data)
      return photo
    } catch {
      throw error
    }
  }

  func savePhoto(_ photo: Photo, for date: String, retryHandler: (() -> Void)?) async throws -> Photo {
    guard photo.mediaType == "image" else {
      throw CosmoPicError.mediaTypeError(retryHandler: retryHandler)
    }
    guard let photoHdURL = photo.hdURL else {
      throw CosmoPicError.savePhotoError
    }

    let fileExtension = photoHdURL.pathExtension
    let localFilename = "\(date).\(fileExtension)"
    let localImagePath = FileManager.appGroupContainerURL.appendingPathComponent(localFilename)

    if !FileManager.default.fileExists(atPath: localImagePath.path) {
      let (imageData, _) = try await URLSession.shared.data(from: photoHdURL)
      try imageData.write(to: localImagePath)
    }

    var updatedPhoto = photo
    updatedPhoto.localFilename = localFilename

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
    let thumbnailFileURL = FileManager.appGroupContainerURL.appendingPathComponent(thumbnailFilename)

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

  func loadPhoto(from jsonPath: URL, for _: String) throws -> Photo {
    do {
      let jsonData = try Data(contentsOf: jsonPath)
      let photo = try JSONDecoder().decodeLogging(Photo.self, from: jsonData)

      if let localFilename = photo.localFilename {
        let localFileURL = FileManager.appGroupContainerURL.appendingPathComponent(localFilename)
        if !FileManager.default.fileExists(atPath: localFileURL.path) {
          throw CosmoPicError.noFileFound
        }
      } else {
        throw CosmoPicError.noFileFound
      }

      return photo
    } catch {
      throw error
    }
  }
}
