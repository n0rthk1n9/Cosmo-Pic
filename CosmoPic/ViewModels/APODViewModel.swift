//
//  APODViewModel.swift
//  CosmoPic
//
//  Created by Jan Armbrust on 02.02.24.
//

import Foundation
import SwiftUI

class APODViewModel: ObservableObject {
  @Published var photo: Photo?
  @Published var isLoading = false
  @Published var error: PhotoAPIServiceAlert?

  private let photoAPIService: PhotoAPIServiceProtocol

  init(photoAPIService: PhotoAPIServiceProtocol = PhotoAPIService()) {
    self.photoAPIService = photoAPIService
  }

  @MainActor
  func fetchPhotoForToday() async {
    isLoading = true
    error = nil

    let currentDate = DateFormatter.yyyyMMdd.string(from: Date())
    let jsonPathURL = FileManager.documentsDirectoryURL.appendingPathComponent("\(currentDate).json")

    do {
      if FileManager.default.fileExists(atPath: jsonPathURL.path) {
        let loadedPhoto = try photoAPIService.loadPhoto(from: jsonPathURL, for: currentDate)
        photo = loadedPhoto
      } else {
        let fetchedPhoto = try await photoAPIService.fetchPhoto(from: currentDate)
        let savedPhoto = try await photoAPIService.savePhoto(
          fetchedPhoto,
          for: currentDate,
          to: FileManager.documentsDirectoryURL
        )

        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let jsonData = try encoder.encode(savedPhoto)
        try jsonData.write(to: jsonPathURL)

        photo = savedPhoto
      }
    } catch {
      self.error = error as? PhotoAPIServiceAlert ?? .other(error: error)
    }

    isLoading = false
  }
}
