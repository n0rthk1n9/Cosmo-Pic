//
//  DataStoreNew.swift
//  CosmoPic
//
//  Created by Jan Armbrust on 28.11.23.
//

import Foundation

class DataStoreNew: ObservableObject {
  @Published var photo: Photo?
  @Published var isLoading = false

  @Published var errorIsPresented = false
  @Published var error: Error?

  let photoAPIService: PhotoAPIServiceProtocol

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
}
