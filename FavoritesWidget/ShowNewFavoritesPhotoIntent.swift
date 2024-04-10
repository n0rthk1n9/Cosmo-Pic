//
//  ShowNewFavoritesPhotoIntent.swift
//  CosmoPic
//
//  Created by Jan Armbrust on 29.03.24.
//

import AppIntents
import WidgetKit

struct ShowNewFavoritesPhotoIntent: AppIntent {
  static var title: LocalizedStringResource = "Refresh Widget"
  static var description: IntentDescription = "Toggles the widget refresh state."

  init() {}

  init(showPreviousPhoto: Bool) {
    self.showPreviousPhoto = showPreviousPhoto
  }

  @Parameter(title: "Refresh State")
  var showPreviousPhoto: Bool

  func perform() async throws -> some IntentResult {
    let sharedDefaults = UserDefaults(suiteName: "group.dev.xbow.Cosmo-Pic")

    let currentIndex = sharedDefaults?.integer(forKey: "currentIndex") ?? 0
    let totalFavoritesCount = sharedDefaults?.integer(forKey: "totalFavoritesCount") ?? 0

    var nextIndex: Int
    if showPreviousPhoto {
      nextIndex = (currentIndex - 1 + totalFavoritesCount) % totalFavoritesCount
    } else {
      nextIndex = (currentIndex + 1) % totalFavoritesCount
    }

    sharedDefaults?.set(nextIndex, forKey: "currentIndex")

    WidgetCenter.shared.reloadAllTimelines()

    return .result()
  }
}
