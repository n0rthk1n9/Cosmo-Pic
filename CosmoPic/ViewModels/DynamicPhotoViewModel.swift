//
//  DynamicPhotoViewModel.swift
//  CosmoPic
//
//  Created by Jan Armbrust on 29.02.24.
//

import Foundation

class DynamicPhotoViewModel: ObservableObject {
  @Published var isSaving = false
  @Published var saveCompleted = false
  @Published var error: CosmoPicError?

  private let imageSaver = ImageSaverService()

  @MainActor
  func saveImage(from url: URL?) async {
    isSaving = true
    do {
      try await imageSaver.saveImage(from: url)
    } catch let error as CosmoPicError {
      self.error = error
    } catch {
      self.error = .other(error: error)
    }

    saveCompleted = true
    isSaving = false
  }
}
