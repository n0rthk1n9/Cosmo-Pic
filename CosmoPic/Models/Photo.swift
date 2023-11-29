//
//  Photo.swift
//  CosmoPic
//
//  Created by Jan Armbrust on 24.11.23.
//

import Foundation

struct Photo: Codable, Equatable {
  let copyright: String?
  let date: String
  let explanation: String
  let hdURL: URL?
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

extension Photo {
  static func fixture(
    copyright: String? = nil,
    date: String = "",
    explanation: String = "",
    hdURL: URL? = nil,
    mediaType: String = "",
    serviceVersion: String = "",
    title: String = "",
    sdURL: URL? = nil,
    localFilename: String? = nil
  ) -> Photo {
    Photo(
      copyright: copyright,
      date: date,
      explanation: explanation,
      hdURL: hdURL,
      mediaType: mediaType,
      serviceVersion: serviceVersion,
      title: title,
      sdURL: sdURL,
      localFilename: localFilename
    )
  }

  static var allProperties: Photo {
    .fixture(
      copyright: "Apple",
      date: "2023-09-04",
      explanation: "This is the logo of Apple Inc.",
      hdURL: URL(
        string: "https://upload.wikimedia.org/wikipedia/commons/thumb/f/fa/Apple_logo_black.svg/1024px-Apple_logo_black.svg.png"
      ),
      mediaType: "image",
      serviceVersion: "v1",
      title: "Apple Logo",
      sdURL: URL(
        string: "https://upload.wikimedia.org/wikipedia/commons/thumb/f/fa/Apple_logo_black.svg/1024px-Apple_logo_black.svg.png"
      ),
      localFilename: "2023-09-04.svg"
    )
  }
}
