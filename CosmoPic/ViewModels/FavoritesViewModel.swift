//
//  FavoritesViewModel.swift
//  CosmoPic
//
//  Created by Jan Armbrust on 03.02.24.
//

import Foundation
import SwiftUI

class FavoritesViewModel: ObservableObject {
  @Published var favorites: [Photo] = []
  @Published var isLoading = false
  @Published var error: Error?
  @Published var errorIsPresented = false

  private let favoritesFileName = "favorites.json"

  init() {
    loadFavorites()
  }

  func loadFavorites() {
    isLoading = true

    let fileManager = FileManager.default
    let favoritesFileURL = FileManager.documentsDirectoryURL.appendingPathComponent(favoritesFileName)

    if fileManager.fileExists(atPath: favoritesFileURL.path) {
      do {
        let jsonData = try Data(contentsOf: favoritesFileURL)
        favorites = try JSONDecoder().decode([Photo].self, from: jsonData)
      } catch {
        self.error = error
        errorIsPresented = true
      }
    }

    isLoading = false
  }

  func addToFavorites(_ photo: Photo) {
    guard !favorites.contains(where: { $0.title == photo.title }) else { return }
    favorites.append(photo)
    saveFavorites()
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
      self.error = error
      errorIsPresented = true
    }
  }

  func isFavorite(_ photo: Photo) -> Bool {
    favorites.contains { $0.title == photo.title }
  }
}
