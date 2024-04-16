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
  @StateObject var router = Router.shared

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
        .environmentObject(router)
        .onOpenURL { url in
          guard let scheme = url.scheme, scheme == "cosmopic" else { return }
          guard let tab = url.host else { return }
          guard let requestedTab = Tab.allCases.first(where: { $0.rawValue == tab }) else { return }
          router.resetPath()
          router.activeTab = requestedTab
          if url.pathComponents.count == 2 {
            let titleOfRequestedFavorite = url.lastPathComponent
            let cleanedTitleOfRequestedFavorite = titleOfRequestedFavorite.replacingOccurrences(of: "%20", with: " ")
            if let foundNameOfRequestedFavorite = favoritesViewModel.favorites.first(
              where: { $0.title == cleanedTitleOfRequestedFavorite }
            ) {
              router.resetPath()
              router.path.append(foundNameOfRequestedFavorite)
              print(foundNameOfRequestedFavorite)
            }
          }
        }
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
      }
    } catch {
      print("Error deleting CFNetworkDownload files: \(error)")
    }
  }
}
