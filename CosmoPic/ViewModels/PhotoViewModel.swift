//
//  PhotoViewModel.swift
//  CosmoPic
//
//  Created by Jan Armbrust on 29.02.24.
//

import Foundation

class PhotoViewModel: ObservableObject {
  @Published var isSaving = false
  @Published var saveCompleted = false
  private let imageSaver = ImageSaverService()

  @MainActor
  func saveImage(from url: URL) async {
    isSaving = true
    await imageSaver.saveImage(from: url)
    saveCompleted = true
    isSaving = false
  }
}
