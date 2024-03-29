//
//  RefreshWidgetToggleIntent.swift
//  CosmoPic
//
//  Created by Jan Armbrust on 29.03.24.
//

import AppIntents
import WidgetKit

struct RefreshWidgetToggleIntent: AppIntent {
  static var title: LocalizedStringResource = "Refresh Widget"
  static var description: IntentDescription = "Toggles the widget refresh state."

  init() {}

  init(refreshState: Bool) {
    self.refreshState = refreshState
  }

  @Parameter(title: "Refresh State")
  var refreshState: Bool

  func perform() async throws -> some IntentResult {
    // Logic to signal the widget to refresh
    let sharedDefaults =
      UserDefaults(suiteName: "group.dev.xbow.Cosmo-Pic") // Replace with your actual app group identifier
    var refreshCount = sharedDefaults?.integer(forKey: "widgetRefreshCount") ?? 0
    refreshCount += 1
    sharedDefaults?.set(refreshCount, forKey: "widgetRefreshCount")

    // Inform the widget system to reload the timelines
    WidgetCenter.shared.reloadAllTimelines()

    // Use .result() to indicate successful completion
    return .result()
  }
}
