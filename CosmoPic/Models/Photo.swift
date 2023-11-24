//
//  Photo.swift
//  CosmoPic
//
//  Created by Jan Armbrust on 24.11.23.
//

import Foundation

struct Photo {
  let copyright: String
  let date: Date
  let explanation: String
  let hdURL: URL
  let mediaType: String
  let serviceVersion: String
  let title: String
  let sdURL: URL

  enum CodingKeys: String, CodingKey {
    case copyright, date, explanation, title
    case hdURL = "hdurl"
    case mediaType = "media_type"
    case serviceVersion = "service_version"
    case sdURL = "url"
  }
}
