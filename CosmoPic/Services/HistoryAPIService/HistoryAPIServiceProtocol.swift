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
  func updatePhotosWithLocalURLs(_ photos: [Photo], onPhotoUpdated: @escaping () -> Void) async throws -> [Photo]
  func updatePhotoWithLocalURL(_ photo: Photo) async throws -> Photo
  func cacheThumbnail(from _: URL, identifier _: String) async throws -> String
  func downloadAndUpdatePhoto(for _: Photo, in _: [Photo], for _: String) async throws -> Int
}
