//
//  JSONDecoderErrorHandler.swift
//  CosmoPic
//
//  Created by Jan Armbrust on 30.11.23.
//

import Foundation

struct JSONDecoderErrorHandler {
  func handleError(error: Error) throws {
    if let decodingError = error as? DecodingError {
      switch decodingError {
      case let .dataCorrupted(context):
        print(context)

      case let .keyNotFound(key, context):
        print("Key '\(key)' not found:", context.debugDescription)
        print("codingPath:", context.codingPath)

      case let .valueNotFound(value, context):
        print("Value '\(value)' not found:", context.debugDescription)
        print("codingPath:", context.codingPath)

      case let .typeMismatch(type, context):
        print("Type '\(type)' mismatch:", context.debugDescription)
        print("codingPath:", context.codingPath)

      @unknown default:
        print("Unknown decoding error: \(decodingError)")
      }
    }
    throw error
  }
}
