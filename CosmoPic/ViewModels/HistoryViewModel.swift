//
//  HistoryViewModel.swift
//  CosmoPic
//
//  Created by Jan Armbrust on 11.02.24.
//

import Foundation
import SwiftUI

class HistoryViewModel: ObservableObject {
  @Published var history: [Photo] = []
  @Published var isLoading = false
  @Published var loadedElements = 0
  @Published var totalElements = 31

  @Published var error: CosmoPicError?

  private let historyAPIService: HistoryAPIServiceProtocol

  init(historyAPIService: HistoryAPIServiceProtocol = HistoryAPIService()) {
    self.historyAPIService = historyAPIService
  }

  @MainActor
  func getHistory() async {
    loadedElements = 0
    isLoading = true
    do {
      let currentDate = Date()
      guard let oneMonthAgo = Calendar.current.date(byAdding: .month, value: -1, to: currentDate) else { return }

      let todayString = DateFormatter.yyyyMMdd.string(from: currentDate)
      let startDate = DateFormatter.yyyyMMdd.string(from: oneMonthAgo)

      let historyFilePath = FileManager.appGroupContainerURL
        .appendingPathComponent("\(todayString)-history.json")

      if history.isEmpty {
        if FileManager.default.fileExists(atPath: historyFilePath.path) {
          history = try historyAPIService.loadHistory(for: todayString)
        } else {
          let fetchedHistory = try await historyAPIService.fetchHistory(
            starting: startDate,
            ending: todayString
          )

          //        let updatedHistory = try await historyAPIService.updatePhotosWithLocalURLs(fetchedHistory) {
          //          Task { @MainActor in
          //            self.loadedElements += 1
          //          }
          //        }

          try historyAPIService.saveHistory(fetchedHistory, for: todayString)
          history = fetchedHistory
        }
      }
    } catch let error as CosmoPicError {
      self.error = error
    } catch {
      self.error = .other(error: error)
    }
    isLoading = false
    await deletOldFiles()
  }

  @MainActor
  func getHistoryPhoto(for photo: Photo) async {
    isLoading = true

    do {
      let currentDate = Date()
      let todayString = DateFormatter.yyyyMMdd.string(from: currentDate)
      guard let photoSdURL = photo.sdURL else {
        throw CosmoPicError.invalidURL
      }
      let fileExtension = photoSdURL.pathExtension
      let thumbnailFilename = "\(photo.date)-thumbnail.\(fileExtension)"
      let thumbnailFileURL = FileManager.appGroupContainerURL.appendingPathComponent(thumbnailFilename)

      if !FileManager.default.fileExists(atPath: thumbnailFileURL.path) {
        let index = try await historyAPIService.downloadAndUpdatePhoto(for: photo, in: history, for: photo.date)

        history[index] = photo
        try historyAPIService.saveHistory(history, for: todayString)
      }
    } catch let error as CosmoPicError {
      self.error = error
    } catch {
      self.error = .other(error: error)
    }
    isLoading = false
  }

  func getFavoriteFilenames() -> Set<String> {
    guard let jsonData = try? Data(contentsOf: FileManager.appGroupContainerURL
      .appendingPathComponent("favorites.json")),
      let favorites = try? JSONDecoder().decode([Photo].self, from: jsonData)
    else {
      return []
    }
    return Set(favorites.compactMap { $0.localFilename })
  }

  func getCutoffDate(from fileURL: URL) -> Date? {
    guard
      let jsonData = try? Data(contentsOf: fileURL),
      let photos = try? JSONDecoder().decode([Photo].self, from: jsonData)
    else {
      return nil
    }
    return photos.compactMap { DateFormatter.yyyyMMdd.date(from: $0.date) }.min()
  }

  func deleteFilesOlderThan(cutoffDate: Date, excluding favorites: Set<String>) {
    guard let fileURLs = try? FileManager.default.contentsOfDirectory(at: FileManager.appGroupContainerURL)
    else { return }

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
      if let fileDate = DateFormatter.yyyyMMdd.date(from: dateString), fileDate < cutoffDate {
        try? FileManager.default.deleteFile(at: fileURL)
      }
    }
  }

  func deleteOlderHistoryFiles(excluding currentDayFileName: String, favorites: Set<String>) {
    guard let fileURLs = try? FileManager.default.contentsOfDirectory(at: FileManager.appGroupContainerURL)
    else { return }

    for fileURL in fileURLs where fileURL.lastPathComponent.hasSuffix("-history.json") {
      let fileName = fileURL.lastPathComponent

      if fileName != currentDayFileName && !favorites.contains(where: { fileName.contains($0) }) {
        try? FileManager.default.deleteFile(at: fileURL)
      }
    }
  }

  func deletOldFiles() async {
    let todayHistoryFileName = "\(DateFormatter.yyyyMMdd.string(from: Date()))-history.json"
    let favoriteFilenames = getFavoriteFilenames()
    let todayHistoryFileURL = FileManager.appGroupContainerURL.appendingPathComponent(todayHistoryFileName)

    if let cutoffDate = getCutoffDate(from: todayHistoryFileURL) {
      // Delete non-history files older than the cutoff date, excluding favorites
      deleteFilesOlderThan(cutoffDate: cutoffDate, excluding: favoriteFilenames)
      // Delete older history files separately
      deleteOlderHistoryFiles(excluding: todayHistoryFileName, favorites: favoriteFilenames)
    }
  }
}
