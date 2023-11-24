//
//  FetchPhotoError.swift
//  CosmoPic
//
//  Created by Jan Armbrust on 25.11.23.
//

import Foundation

enum FetchPhotoError: Error {
  case invalidURL
  case invalidResponse
  case requestFailed
  case decodingFailed
}
