//
//  DataStore.swift
//  CosmoPic
//
//  Created by Jan Armbrust on 28.11.23.
//

import Foundation

class DataStore: ObservableObject {
  @Published var photo: Photo?
  @Published var history: [Photo] = []
  @Published var favorites: [Photo] = []
  @Published var isLoading = false
  @Published var loadedHistoryElements = 0
  @Published var totalHistoryElements = 31

  @Published var errorIsPresented = false
  @Published var error: Error?

  private let favoritesFileName = "favorites.json"

  let photoAPIService: PhotoAPIServiceProtocol
  let historyAPIService: HistoryAPIServiceProtocol

  init(
    photoAPIService: PhotoAPIServiceProtocol = PhotoAPIService(),
    historyAPIService: HistoryAPIServiceProtocol = HistoryAPIService()
  ) {
    self.photoAPIService = photoAPIService
    self.historyAPIService = historyAPIService
  }

  @MainActor
  func getPhoto(for date: String) async {
    photo = nil
    isLoading = true
    let jsonPathURL = FileManager.documentsDirectoryURL.appendingPathComponent("\(date).json")

    do {
      if FileManager.default.fileExists(atPath: jsonPathURL.path) {
        let loadedPhoto = try photoAPIService.loadPhoto(from: jsonPathURL, for: date)
        photo = loadedPhoto
      } else {
        let fetchedPhoto = try await photoAPIService.fetchPhoto(from: date)
        let savedPhoto = try await photoAPIService.savePhoto(
          fetchedPhoto,
          for: date,
          to: FileManager.documentsDirectoryURL
        )

        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let jsonData = try encoder.encode(savedPhoto)
        try jsonData.write(to: jsonPathURL)

        photo = savedPhoto
      }
    } catch {
      self.error = error
      errorIsPresented = true
    }

    isLoading = false
  }

  @MainActor
  func getHistory() async {
    isLoading = true
    do {
      let dateFormatter = DateFormatter()
      dateFormatter.dateFormat = "yyyy-MM-dd"
      let currentDate = Date()
      guard let oneMonthAgo = Calendar.current.date(byAdding: .month, value: -1, to: currentDate) else { return }

      let todayString = dateFormatter.string(from: currentDate)
      let startDate = dateFormatter.string(from: oneMonthAgo)

      let historyFilePath = FileManager.documentsDirectoryURL
        .appendingPathComponent("\(todayString)-history.json")

      if FileManager.default.fileExists(atPath: historyFilePath.path) {
        history = try historyAPIService.loadHistory(for: todayString)
      } else {
        let fetchedHistory = try await historyAPIService.fetchHistory(
          starting: startDate,
          ending: todayString
        )

        let updatedHistory = try await historyAPIService.updatePhotosWithLocalURLs(
          fetchedHistory,
          dateFormatter: dateFormatter
        ) {
          Task { @MainActor in
            self.loadedHistoryElements += 1
          }
        }

        try historyAPIService.saveHistory(updatedHistory, for: todayString)
        history = updatedHistory
      }
    } catch {
      self.error = error
      errorIsPresented = true
    }
    isLoading = false
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
      self.error = error
      errorIsPresented = true
    }
  }

  func isFavorite(_ photo: Photo) -> Bool {
    return favorites.contains { $0.title == photo.title }
  }
}
