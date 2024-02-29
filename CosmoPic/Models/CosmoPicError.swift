//
//  CosmoPicError.swift
//  CosmoPic
//
//  Created by Jan Armbrust on 25.11.23.
//

import SwiftUI

enum CosmoPicError: Error, LocalizedError, CosmoPicAlert {
  case invalidURL
  case invalidResponseCode
  case photoForTodayNotAvailableYet(retryHandler: (() -> Void)?)
  case savePhotoError
  case mediaTypeError(retryHandler: (() -> Void)?)
  case noFileFound
  case other(error: Error)

  var title: String {
    switch self {
    case .invalidURL:
      return "Something went wrong while creating the URL to download content"
    case .invalidResponseCode:
      return "Something went wrong while downloading the content"
    case .photoForTodayNotAvailableYet:
      return "The photo for today is not available yet"
    case .mediaTypeError:
      return "Todays photo is actually a video and can not be displayed."
    case .savePhotoError:
      return "Found no photo to save"
    case .noFileFound:
      return "The cached photo can not be loaded"
    case .other:
      return "Error"
    }
  }

  var subtitle: String? {
    switch self {
    case .invalidURL:
      return "Please try again later"
    case .invalidResponseCode:
      return "Please try again later"
    case .photoForTodayNotAvailableYet:
      return "Do you want to load yesterdays photo?"
    case .mediaTypeError:
      return "Do you want to load yesterdays photo?"
    case .savePhotoError:
      return "Try again later"
    case .noFileFound:
      return "Do you want to try downloading it again?"
    case let .other(error):
      return error.localizedDescription
    }
  }

  var buttons: AnyView {
    AnyView(getButtonsForAlert)
  }

  @ViewBuilder var getButtonsForAlert: some View {
    switch self {
    case let .photoForTodayNotAvailableYet(retryHandler):
      Button("No") {}
      Button("Yes") {
        retryHandler?()
      }
    case let .mediaTypeError(retryHandler):
      Button("No") {}
      Button("Yes") {
        retryHandler?()
      }
    default:
      Button("OK") {}
    }
  }
}
