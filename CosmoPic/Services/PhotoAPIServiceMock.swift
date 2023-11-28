//
//  PhotoAPIServiceMock.swift
//  CosmoPic
//
//  Created by Jan Armbrust on 28.11.23.
//

import Foundation

struct PhotoAPIServiceMock: PhotoAPIServiceProtocol {
  var photoResponse: Photo = .allProperties

  func fetchPhoto(from _: String) async throws -> Photo {
    photoResponse
  }

  func savePhoto(_: Photo, for _: String, to _: URL) async throws -> Photo {
    photoResponse
  }

  func loadPhoto(from _: URL, for _: String) throws -> Photo {
    photoResponse
  }
}
