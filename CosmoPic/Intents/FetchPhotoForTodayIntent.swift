//
//  FetchPhotoForTodayIntent.swift
//  CosmoPic
//
//  Created by Jan Armbrust on 13.04.24.
//

import AppIntents

struct FetchPhotoForTodayIntent: AppIntent {
  static let title: LocalizedStringResource = "Show today's photo"
  static let description: LocalizedStringResource = "Loads and shows today's space photo"

  static let openAppWhenRun = true

  func perform() async throws -> some IntentResult {
    let viewModel = TodayViewModel()

    await viewModel.fetchPhotoForToday()

    return .result()
  }
}
