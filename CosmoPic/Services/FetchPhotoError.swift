//
//  FetchPhotoError.swift
//  CosmoPic
//
//  Created by Jan Armbrust on 25.11.23.
//

import Foundation

enum FetchPhotoError: LocalizedError {
  case invalidURL
  case invalidResponseCode
  case photoForTodayNotAvailableYet
  case savePhotoError
  case noFileFound

  var errorDescription: String? {
    switch self {
    case .invalidURL:
      return "Soemthing went wrong while creating the URL to download the photo"
    case .invalidResponseCode:
      return "Something went wrong while downloading the photo"
    case .photoForTodayNotAvailableYet:
      return "The photo for today is not available yet do you want to load yesterdays photo?"
    case .savePhotoError:
      return "The file can not be saved"
    case .noFileFound:
      return "The cached photo can not be loaded"
    }
  }

  var recoverySuggestion: String? {
    switch self {
    case .invalidURL:
      return "Try again later"
    case .invalidResponseCode:
      return "Try again later"
    case .photoForTodayNotAvailableYet:
      return "Do you want to load yesterdays photo?"
    case .savePhotoError:
      return "Try again later"
    case .noFileFound:
      return "Do you want to try downloading it again?"
    }
  }
}
