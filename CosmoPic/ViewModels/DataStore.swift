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
  }
}
