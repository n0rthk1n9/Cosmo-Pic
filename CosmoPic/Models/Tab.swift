//
//  Tab.swift
//  CosmoPic
//
//  Created by Jan Armbrust on 14.04.24.
//

enum Tab: String, CaseIterable {
  case today = "Today"
  case favorites = "Favorites"
  case history = "History"
  case trivia = "Trivia"

  var tabSymbol: String {
    switch self {
    case .today: "calendar"
    case .favorites: "star"
    case .history: "photo.stack"
    case .trivia: "doc.text"
    }
  }

  static func convert(from: String) -> Self? {
    return Tab.allCases.first { tab in
      tab.rawValue.lowercased() == from.lowercased()
    }
  }
}
