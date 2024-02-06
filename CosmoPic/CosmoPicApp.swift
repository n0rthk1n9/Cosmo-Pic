//
//  CosmoPicApp.swift
//  CosmoPic
//
//  Created by Jan Armbrust on 20.11.23.
//

import SwiftUI

@main
struct CosmoPicApp: App {
  @StateObject var dataStore = DataStore()
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
        .environmentObject(dataStore)
        .environmentObject(favoritesViewModel)
    }
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

      for fileURL in tmpDirectoryContents {
        if fileURL.path.contains("CFNetworkDownload") {
          try fileManager.removeItem(at: fileURL)
          print("Deleted: \(fileURL.lastPathComponent)")
        }
      }
    } catch {
      print("Error deleting CFNetworkDownload files: \(error)")
    }
  }
}
