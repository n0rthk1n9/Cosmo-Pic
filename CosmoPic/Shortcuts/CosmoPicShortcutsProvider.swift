//
//  CosmoPicShortcutsProvider.swift
//  CosmoPic
//
//  Created by Jan Armbrust on 13.04.24.
//

import AppIntents

struct CosmoPicShortcutsProvider: AppShortcutsProvider {
  static var appShortcuts: [AppShortcut] {
    AppShortcut(
      intent: FetchPhotoForTodayIntent(),
      phrases: [
        "Show today's \(.applicationName) photo",
        "Show today's photo in \(.applicationName)",
        "Show today's space photo"
      ],
      shortTitle: "Today's photo",
      systemImageName: "photo.fill"
    )
  }
}
