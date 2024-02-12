//
//  PhotoAPIService.swift
//  CosmoPic
//
//  Created by Jan Armbrust on 28.11.23.
//

import Foundation

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

  func fetchPhoto(from date: String) async throws -> Photo {
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
      guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 404 {
          let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
          if json?["msg"] as? String == "No data available for date: \(date)" {
            throw FetchPhotoError.photoForTodayNotAvailableYet
          }
        }
        throw FetchPhotoError.invalidResponseCode
      }

      let photo = try JSONDecoder().decodeLogging(Photo.self, from: data)
      return photo
    } catch {
      throw error
    }
  }

  func savePhoto(_ photo: Photo, for date: String, to directory: URL) async throws -> Photo {
    guard photo.mediaType == "image", let photoHdURL = photo.hdURL else {
      throw FetchPhotoError.savePhotoError
    }

    let fileExtension = photoHdURL.pathExtension
    let localFilename = "\(date).\(fileExtension)"
    let localImagePath = directory.appendingPathComponent(localFilename)

    if !FileManager.default.fileExists(atPath: localImagePath.path) {
      let (imageData, _) = try await URLSession.shared.data(from: photoHdURL)
      try imageData.write(to: localImagePath)
    }

    var updatedPhoto = photo
    updatedPhoto.localFilename = localFilename
    return updatedPhoto
  }

  func loadPhoto(from jsonPath: URL, for _: String) throws -> Photo {
    do {
      let jsonData = try Data(contentsOf: jsonPath)
      let photo = try JSONDecoder().decodeLogging(Photo.self, from: jsonData)

      if let localFilename = photo.localFilename {
        let localFileURL = FileManager.documentsDirectoryURL.appendingPathComponent(localFilename)
        if !FileManager.default.fileExists(atPath: localFileURL.path) {
          throw FetchPhotoError.noFileFound
        }
      } else {
        throw FetchPhotoError.noFileFound
      }

      return photo
    } catch {
      throw error
    }
  }
}
