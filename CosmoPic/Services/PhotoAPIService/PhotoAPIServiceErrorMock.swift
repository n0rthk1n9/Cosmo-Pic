//
//  PhotoAPIServiceErrorMock.swift
//  CosmoPic
//
//  Created by Jan Armbrust on 28.11.23.
//

import Foundation

struct PhotoAPIServiceErrorMock: PhotoAPIServiceProtocol {
  enum SomeError: LocalizedError {
    case anError

    var errorDescription: String? {
      "AnError"
    }
  }

  func fetchPhoto(from _: String, retryHandler _: (() -> Void)?) async throws -> Photo {
    throw SomeError.anError
  }

  func savePhoto(_: Photo, for _: String, to _: URL, retryHandler _: (() -> Void)?) async throws -> Photo {
    throw SomeError.anError
  }

  func loadPhoto(from _: URL, for _: String) throws -> Photo {
    throw SomeError.anError
  }
}
