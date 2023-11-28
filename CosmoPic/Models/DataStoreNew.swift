//
//  DataStoreNew.swift
//  CosmoPic
//
//  Created by Jan Armbrust on 28.11.23.
//

import Foundation

class DataStoreNew: ObservableObject {
  @Published var photo: Photo?
  @Published var history: [Photo] = []
  @Published var isLoading = false

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
  func getPhoto(for date: String) async {
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

  func getLocalFileURL(forFilename filename: String) -> URL {
    return FileManager.documentsDirectoryURL.appendingPathComponent(filename)
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
        let fetchedHistory = try await historyAPIService.fetchHistory(starting: startDate, ending: todayString)

        let updatedHistory = try await historyAPIService.updatePhotosWithLocalURLs(
          fetchedHistory,
          dateFormatter: dateFormatter
        )

        try historyAPIService.saveHistory(updatedHistory, for: todayString)

        history = updatedHistory
      }
    } catch {
      self.error = error
      errorIsPresented = true
    }
    isLoading = false
  }
}
