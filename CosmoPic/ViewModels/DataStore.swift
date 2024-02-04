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

  func deleteOldHistoryAndPhotos() async {
    let fileManager = FileManager.default
    let documentsDirectory = FileManager.documentsDirectoryURL
    let currentDate = Date()
    guard let oneMonthAgo = Calendar.current.date(byAdding: .month, value: -1, to: currentDate) else { return }

    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    let todayString = dateFormatter.string(from: currentDate)
    let todayHistoryFileName = "\(todayString)-history.json"

    // Load favorite photo filenames
    var favoriteFilenames: Set<String> = []
    let favoritesFileURL = documentsDirectory.appendingPathComponent("favorites.json")
    if let jsonData = try? Data(contentsOf: favoritesFileURL),
       let favorites = try? JSONDecoder().decode([Photo].self, from: jsonData)
    {
      favoriteFilenames = Set(favorites.compactMap { $0.localFilename })
    }

    do {
      let fileURLs = try fileManager.contentsOfDirectory(
        at: documentsDirectory,
        includingPropertiesForKeys: [.creationDateKey],
        options: .skipsHiddenFiles
      )

      for fileURL in fileURLs {
        let fileName = fileURL.lastPathComponent

        // Skip today's history file, favorites file, and any file related to a favorited photo
        if fileName == todayHistoryFileName || fileName == "favorites.json" || favoriteFilenames
          .contains(fileName)
        {
          continue
        }

        // For history files, delete if not today's (no need to check date for these, just the name)
        if fileName.hasSuffix("-history.json") && fileName != todayHistoryFileName {
          try fileManager.removeItem(at: fileURL)
          continue
        }

        // For other files, check if they are older than one month and not favorited
        let fileAttributes = try fileManager.attributesOfItem(atPath: fileURL.path)
        if let creationDate = fileAttributes[.creationDate] as? Date, creationDate < oneMonthAgo {
          try fileManager.removeItem(at: fileURL)
        }
      }
    } catch {
      print("Failed to delete old files: \(error)")
      // Optionally handle the error, e.g., log or display to the user
    }
  }
}
