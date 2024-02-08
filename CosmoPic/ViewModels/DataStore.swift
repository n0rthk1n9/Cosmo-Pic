//
//  DataStore.swift
//  CosmoPic
//
//  Created by Jan Armbrust on 28.11.23.
//

import Foundation

class DataStore: ObservableObject {
  @Published var history: [Photo] = []
  @Published var isLoadingHistory = false
  @Published var loadedHistoryElements = 0
  @Published var totalHistoryElements = 31

  @Published var errorIsPresented = false
  @Published var error: Error?

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
  func getHistory() async {
    loadedHistoryElements = 0
    isLoadingHistory = true
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
    isLoadingHistory = false
    await deleteOldHistoryAndPhotos()
  }

  func loadFavoriteFilenames() -> Set<String> {
    guard let jsonData = try? Data(contentsOf: FileManager.documentsDirectoryURL
      .appendingPathComponent("favorites.json")),
      let favorites = try? JSONDecoder().decode([Photo].self, from: jsonData)
    else {
      return []
    }
    return Set(favorites.compactMap { $0.localFilename })
  }

  func determineOldestDateToKeep(from fileURL: URL) -> Date? {
    guard let jsonData = try? Data(contentsOf: fileURL),
          let photos = try? JSONDecoder().decode([Photo].self, from: jsonData)
    else {
      return nil
    }
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    return photos.compactMap { dateFormatter.date(from: $0.date) }.min()
  }

  func deleteFilesOlderThan(cutoffDate: Date, excluding favorites: Set<String>) {
    guard let fileURLs = try? FileManager.default.contentsOfDirectory(at: FileManager.documentsDirectoryURL)
    else { return }

    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"

    for fileURL in fileURLs {
      let fileName = fileURL.lastPathComponent

      // Skip specific non-deletable files and favorites
      if fileName == "favorites.json" || favorites.contains(where: { fileName.contains($0) }) {
        continue
      }

      // Skip history files for special handling
      if fileName.hasSuffix("-history.json") {
        continue
      }

      // Delete based on date comparison for other files
      let dateString = String(fileName.prefix(10))
      if let fileDate = dateFormatter.date(from: dateString), fileDate < cutoffDate {
        try? FileManager.default.deleteFile(at: fileURL)
      }
    }
  }

  func deleteOlderHistoryFiles(excluding currentDayFileName: String, favorites: Set<String>) {
    guard let fileURLs = try? FileManager.default.contentsOfDirectory(at: FileManager.documentsDirectoryURL)
    else { return }

    for fileURL in fileURLs where fileURL.lastPathComponent.hasSuffix("-history.json") {
      let fileName = fileURL.lastPathComponent

      if fileName != currentDayFileName && !favorites.contains(where: { fileName.contains($0) }) {
        try? FileManager.default.deleteFile(at: fileURL)
      }
    }
  }

  func deleteOldHistoryAndPhotos() async {
    let dateFormatter = DateFormatter.yyyyMMdd
    let todayHistoryFileName = "\(dateFormatter.string(from: Date()))-history.json"
    let favoriteFilenames = loadFavoriteFilenames()
    let todayHistoryFileURL = FileManager.documentsDirectoryURL.appendingPathComponent(todayHistoryFileName)

    if let cutoffDate = determineOldestDateToKeep(from: todayHistoryFileURL) {
      // Delete non-history files older than the cutoff date, excluding favorites
      deleteFilesOlderThan(cutoffDate: cutoffDate, excluding: favoriteFilenames)
      // Delete older history files separately
      deleteOlderHistoryFiles(excluding: todayHistoryFileName, favorites: favoriteFilenames)
    }
  }
}
