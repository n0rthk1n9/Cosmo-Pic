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
