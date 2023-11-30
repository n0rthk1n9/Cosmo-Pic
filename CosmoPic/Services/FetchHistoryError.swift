//
//  FetchHistoryError.swift
//  CosmoPic
//
//  Created by Jan Armbrust on 30.11.23.
//

import Foundation

enum FetchHistoryError: Error {
  case invalidURL
  case invalidResponseCode
}

extension FetchHistoryError: LocalizedError {
  var errorDescription: String? {
    switch self {
    case .invalidURL:
      return NSLocalizedString("Soemthing went wrong while creating the URL to download the photo", comment: "")
    case .invalidResponseCode:
      return NSLocalizedString("Soemthing went wrong while downloading the photo", comment: "")
    }
  }
}
