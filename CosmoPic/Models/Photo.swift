//
//  Photo.swift
//  CosmoPic
//
//  Created by Jan Armbrust on 24.11.23.
//

import Foundation

struct Photo: Codable {
  let copyright: String?
  let date: String
  let explanation: String
  var hdURL: URL?
  let mediaType: String
  let serviceVersion: String
  let title: String
  let sdURL: URL?
  var localFilename: String?

  enum CodingKeys: String, CodingKey {
    case copyright, date, explanation, title, localFilename
    case hdURL = "hdurl"
    case mediaType = "media_type"
    case serviceVersion = "service_version"
    case sdURL = "url"
  }
}
