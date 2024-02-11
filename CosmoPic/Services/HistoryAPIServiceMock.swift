//
//  HistoryAPIServiceMock.swift
//  CosmoPic
//
//  Created by Jan Armbrust on 28.11.23.
//

import Foundation

struct HistoryAPIServiceMock: HistoryAPIServiceProtocol {
  var historyResponse: [Photo] = [.allProperties, .allProperties]
  var photoResponse: Photo = .allProperties

  func fetchHistory(starting _: String, ending _: String) async throws -> [Photo] {
    historyResponse
  }

  func saveHistory(_: [Photo], for _: String) throws {}

  func loadHistory(for _: String) throws -> [Photo] {
    historyResponse
  }

  func updatePhotosWithLocalURLs(_: [Photo], onPhotoUpdated _: @escaping () -> Void) async throws -> [Photo] {
    historyResponse
  }

  func updatePhotoWithLocalURL(_: Photo) async throws -> Photo {
    photoResponse
  }

  func cacheThumbnail(from _: URL, identifier _: String) async throws -> String {
    "2023-09-04.jpg"
  }
}
