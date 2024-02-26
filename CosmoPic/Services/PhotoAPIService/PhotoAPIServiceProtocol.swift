//
//  PhotoAPIServiceProtocol.swift
//  CosmoPic
//
//  Created by Jan Armbrust on 28.11.23.
//

import Foundation

protocol PhotoAPIServiceProtocol {
  func fetchPhoto(from date: String, retryHandler: (() -> Void)?) async throws -> Photo
  func savePhoto(_ photo: Photo, for date: String, retryHandler: (() -> Void)?) async throws -> Photo
  func loadPhoto(from jsonPath: URL, for _: String) throws -> Photo
}
