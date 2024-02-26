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
  func fetchPhotoFor(date: Date) async {
    isLoading = true
    error = nil

    let currentDate = DateFormatter.yyyyMMdd.string(from: date)
    let jsonPathURL = FileManager.documentsDirectoryURL.appendingPathComponent("\(currentDate).json")

    do {
      if FileManager.default.fileExists(atPath: jsonPathURL.path) {
        let loadedPhoto = try photoAPIService.loadPhoto(from: jsonPathURL, for: currentDate)
        photo = loadedPhoto
      } else {
        let fetchedPhoto = try await photoAPIService.fetchPhoto(from: currentDate) {
          Task {
            await self.fetchPhotoForYesterday()
          }
        }
        let savedPhoto = try await photoAPIService.savePhoto(fetchedPhoto, for: currentDate) {
          Task {
            await self.fetchPhotoForYesterday()
          }
        }

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

  @MainActor
  func fetchPhotoForYesterday() async {
    guard let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date()) else {
      return
    }

    Task {
      await fetchPhotoFor(date: yesterday)
    }
  }

  @MainActor
  func fetchPhotoForToday() async {
    let today = Date()

    Task {
      await fetchPhotoFor(date: today)
    }
  }
}
