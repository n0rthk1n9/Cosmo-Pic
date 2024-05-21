//
//  FavoritesViewModel.swift
//  CosmoPic
//
//  Created by Jan Armbrust on 03.02.24.
//

import Foundation
import SwiftUI
import WidgetKit

class FavoritesViewModel: ObservableObject {
  @Published var favorites: [Photo] = []
  @Published var recentlyDeletedFavorites: [Photo] = []
  @Published var isLoading = false
  @Published var error: Error?
  @Published var errorIsPresented = false

  private let favoritesFileName = "favorites.json"
  private let recentlyDeletedFavoritesFileName = "recentlyDeletedFavorites.json"

  init() {
    loadFavorites()
    loadRecentlyDeletedFavorites()
  }

  func loadFavorites() {
    isLoading = true

    let favoritesFileURL = FileManager.appGroupContainerURL.appendingPathComponent(favoritesFileName)

    if FileManager.default.fileExists(atPath: favoritesFileURL.path) {
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

  func loadRecentlyDeletedFavorites() {
    isLoading = true

    let recentlyDeletedFavoritesFileURL = FileManager.appGroupContainerURL
      .appendingPathComponent(recentlyDeletedFavoritesFileName)

    if FileManager.default.fileExists(atPath: recentlyDeletedFavoritesFileURL.path) {
      do {
        let jsonData = try Data(contentsOf: recentlyDeletedFavoritesFileURL)
        recentlyDeletedFavorites = try JSONDecoder().decode([Photo].self, from: jsonData)
      } catch {
        self.error = error
        errorIsPresented = true
      }
    }

    isLoading = false
  }

  func isFavorite(_ photo: Photo) -> Bool {
    favorites.contains { $0.title == photo.title }
  }

  func isRecentlyDeletedFavorite(_ photo: Photo) -> Bool {
    recentlyDeletedFavorites.contains { $0.title == photo.title }
  }

  func toggleFavoriteStatus(for photo: Photo) {
    if isFavorite(photo) {
      removeFromFavorites(photo)
    } else {
      addToFavorites(photo)
      removeFromRecentlyDeletedFavorites(photo)
    }
  }

  private func addToFavorites(_ photo: Photo) {
    guard !isFavorite(photo) else { return }
    favorites.append(photo)
    saveFavorites()
  }

  private func addToRecentlyDeletedFavorites(_ photo: Photo) {
    guard !isRecentlyDeletedFavorite(photo) else { return }
    recentlyDeletedFavorites.append(photo)
    saveRecentlyDeletedFavorites()
  }

  private func removeFromFavorites(_ photo: Photo) {
    favorites.removeAll { $0.title == photo.title }
    let currentDateString = DateFormatter.yyyyMMdd.string(from: Date())
    var modifiedPhoto = photo
    modifiedPhoto.deletionFromFavoritesDate = currentDateString
    addToRecentlyDeletedFavorites(modifiedPhoto)
    saveFavorites()
  }

  func removeFromRecentlyDeletedFavorites(_ photo: Photo) {
    recentlyDeletedFavorites.removeAll { $0.title == photo.title }
    saveRecentlyDeletedFavorites()
  }

  func purgeOldRecentlyDeletedFavorites() {
    let currentDate = Date()
    recentlyDeletedFavorites.removeAll { photo in
      if let deletionDateString = photo.deletionFromFavoritesDate,
         let deletionDate = DateFormatter.yyyyMMdd.date(from: deletionDateString)
      {
        return currentDate.timeIntervalSince(deletionDate) > 30 * 24 * 60 * 60
      }
      return false
    }
    saveRecentlyDeletedFavorites()
  }

  private func saveFavorites() {
    let favoritesFileURL = FileManager.appGroupContainerURL.appendingPathComponent(favoritesFileName)

    do {
      let encoder = JSONEncoder()
      encoder.outputFormatting = .prettyPrinted
      let jsonData = try encoder.encode(favorites)
      try jsonData.write(to: favoritesFileURL)
      WidgetCenter.shared.reloadAllTimelines()
    } catch {
      self.error = error
      errorIsPresented = true
    }
  }

  private func saveRecentlyDeletedFavorites() {
    let recentlyDeletedFavoritesFileURL = FileManager.appGroupContainerURL
      .appendingPathComponent(recentlyDeletedFavoritesFileName)

    do {
      let encoder = JSONEncoder()
      encoder.outputFormatting = .prettyPrinted
      let jsonData = try encoder.encode(recentlyDeletedFavorites)
      try jsonData.write(to: recentlyDeletedFavoritesFileURL)
      WidgetCenter.shared.reloadAllTimelines()
    } catch {
      self.error = error
      errorIsPresented = true
    }
  }
}
