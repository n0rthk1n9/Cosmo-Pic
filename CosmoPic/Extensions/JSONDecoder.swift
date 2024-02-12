//
//  JSONDecoder.swift
//  CosmoPic
//
//  Created by Jan Armbrust on 12.02.24.
//

import Foundation

extension JSONDecoder {
  func decodeLogging<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
    do {
      return try decode(type, from: data)
    } catch let error as DecodingError {
      switch error {
      case let .dataCorrupted(context):
        print("Data corrupted: \(context)")
      case let .keyNotFound(key, context):
        print("Key '\(key)' not found: \(context.debugDescription), codingPath: \(context.codingPath)")
      case let .valueNotFound(value, context):
        print("Value '\(value)' not found: \(context.debugDescription), codingPath: \(context.codingPath)")
      case let .typeMismatch(type, context):
        print("Type '\(type)' mismatch: \(context.debugDescription), codingPath: \(context.codingPath)")
      @unknown default:
        print("Unknown decoding error: \(error)")
      }
      throw error
    } catch {
      throw error
    }
  }
}
