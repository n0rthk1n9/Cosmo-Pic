//
//  HistoryAPIServiceAlert.swift
//  CosmoPic
//
//  Created by Jan Armbrust on 30.11.23.
//

import SwiftUI

enum HistoryAPIServiceAlert: Error, LocalizedError, CosmoPicAlert {
  case invalidURL
  case invalidResponseCode
  case other(error: Error)

  var title: String {
    switch self {
    case .invalidURL:
      return "Soemthing went wrong while creating the URL to download the history"
    case .invalidResponseCode:
      return "Something went wrong while downloading the history"
    case .other:
      return "Error"
    }
  }

  var subtitle: String? {
    switch self {
    case .invalidURL:
      return "Try again later"
    case .invalidResponseCode:
      return "Try again later"
    case let .other(error):
      return error.localizedDescription
    }
  }

  var buttons: AnyView {
    AnyView(getButtonsForAlert)
  }

  @ViewBuilder var getButtonsForAlert: some View {
    switch self {
    default:
      Button("OK") {}
    }
  }
}
