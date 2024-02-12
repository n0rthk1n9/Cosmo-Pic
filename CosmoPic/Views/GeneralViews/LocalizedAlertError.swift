//
//  LocalizedAlertError.swift
//  CosmoPic
//
//  Created by Jan Armbrust on 12.02.24.
//

import Foundation

struct LocalizedAlertError: LocalizedError {
  let underlyingError: LocalizedError
  var errorDescription: String? {
    underlyingError.errorDescription
  }

  var recoverySuggestion: String? {
    underlyingError.recoverySuggestion
  }

  init?(error: Error?) {
    guard let localizedError = error as? LocalizedError else { return nil }
    underlyingError = localizedError
  }
}
