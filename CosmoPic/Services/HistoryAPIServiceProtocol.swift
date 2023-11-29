//
//  HistoryAPIServiceProtocol.swift
//  CosmoPic
//
//  Created by Jan Armbrust on 28.11.23.
//

import Foundation

protocol HistoryAPIServiceProtocol {
  func fetchHistory(starting startDate: String, ending endDate: String) async throws -> [Photo]
  func saveHistory(_ history: [Photo], for date: String) throws
  func loadHistory(for date: String) throws -> [Photo]
  func updatePhotosWithLocalURLs(
    _ photos: [Photo],
    dateFormatter: DateFormatter,
    onPhotoUpdated: @escaping () -> Void
  ) async throws -> [Photo]
  func updatePhotoWithLocalURL(_ photo: Photo, dateFormatter: DateFormatter) async throws -> Photo
  func cacheImage(from url: URL, identifier: String) async throws -> String
}
