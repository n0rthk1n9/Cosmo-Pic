//
//  CosmoPicApp.swift
//  CosmoPic
//
//  Created by Jan Armbrust on 20.11.23.
//

import SwiftUI

@main
struct CosmoPicApp: App {
  @StateObject var favoritesViewModel = FavoritesViewModel()

  init() {
    if ProcessInfo.processInfo.arguments.contains("UITesting") {
      UserDefaults.standard.set(false, forKey: "WelcomeScreenShown")
    }
    deleteCFNetworkDownloadFiles()
  }

  var body: some Scene {
    WindowGroup {
      MainView()
        .environmentObject(favoritesViewModel)
        .cosmoPicStore()
    }

    #if os(visionOS)
      WindowGroup(for: Photo.self) { $photo in
        if let photo {
          PhotoDetailView(photo: photo)
            .environmentObject(favoritesViewModel)
        }
      }
    #endif
  }

  // TODO: Move somwhere else and refactor
  func deleteCFNetworkDownloadFiles() {
    let fileManager = FileManager.default
    let tmpDirectory = FileManager.default.temporaryDirectory

    do {
      let tmpDirectoryContents = try fileManager.contentsOfDirectory(
        at: tmpDirectory,
        includingPropertiesForKeys: nil,
        options: []
      )

      for fileURL in tmpDirectoryContents where fileURL.path.contains("CFNetworkDownload") {
        try fileManager.removeItem(at: fileURL)
        print("Deleted: \(fileURL.lastPathComponent)")
      }
    } catch {
      print("Error deleting CFNetworkDownload files: \(error)")
    }
  }
}
