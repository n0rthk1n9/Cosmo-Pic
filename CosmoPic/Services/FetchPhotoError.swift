//
//  FetchPhotoError.swift
//  CosmoPic
//
//  Created by Jan Armbrust on 25.11.23.
//

import Foundation

enum FetchPhotoError: Error {
  case invalidURL
  case invalidResponseCode
  case photoForTodayNotAvailableYet
  case savePhotoError
  case noFileFound
}

extension FetchPhotoError: LocalizedError {
  var errorDescription: String? {
    switch self {
    case .invalidURL:
      return NSLocalizedString("Soemthing went wrong while creating the URL to download the photo", comment: "")
    case .invalidResponseCode:
      return NSLocalizedString("Soemthing went wrong while downloading the photo", comment: "")
    case .photoForTodayNotAvailableYet:
      return NSLocalizedString(
        "The photo for today is not available yet, do you want to load yesterdays photo?",
        comment: ""
      )
    case .savePhotoError:
      return NSLocalizedString(
        "The file can not be saved because it is not an image",
        comment: ""
      )
    case .noFileFound:
      return NSLocalizedString(
        "The cached photo can not be loaded",
        comment: ""
      )
    }
  }
}
