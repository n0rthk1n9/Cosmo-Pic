//
//  PhotoDetailViewModel.swift
//  CosmoPic
//
//  Created by Jan Armbrust on 04.02.24.
//

import Foundation
import SwiftUI

class PhotoDetailViewModel: ObservableObject {
  @Published var photo: Photo?
  @Published var isLoading = false
  @Published var error: PhotoAPIServiceAlert?

  private let photoAPIService: PhotoAPIServiceProtocol

  init(photoAPIService: PhotoAPIServiceProtocol = PhotoAPIService()) {
    self.photoAPIService = photoAPIService
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
        let fetchedPhoto = try await photoAPIService.fetchPhoto(from: date) {
          print("error")
        }
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
    } catch let error as PhotoAPIServiceAlert {
      self.error = error
    } catch {
      self.error = .other(error: error)
    }

    isLoading = false
  }
}
