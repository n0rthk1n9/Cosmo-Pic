//
//  FileManager.swift
//  CosmoPic
//
//  Created by Jan Armbrust on 27.11.23.
//

import Foundation

public extension FileManager {
  static var documentsDirectoryURL: URL {
    return `default`.urls(for: .documentDirectory, in: .userDomainMask)[0]
  }

  static var appGroupContainerURL: URL {
    return getAppGroupContainerURL(forSecurityApplicationGroupIdentifier: "group.dev.xbow.Cosmo-Pic")
  }

  static func getAppGroupContainerURL(forSecurityApplicationGroupIdentifier groupIdentifier: String) -> URL {
    if let appGroupContainerURL = `default`.containerURL(forSecurityApplicationGroupIdentifier: groupIdentifier) {
      return appGroupContainerURL
    } else {
      return documentsDirectoryURL
    }
  }

  static func localFileURL(for filename: String) -> URL {
    return appGroupContainerURL.appendingPathComponent(filename)
  }

  func fileExists(at url: URL) -> Bool {
    return fileExists(atPath: url.path)
  }

  func deleteFile(at url: URL) throws {
    try removeItem(at: url)
  }

  func contentsOfDirectory(at url: URL) throws -> [URL] {
    return try contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
  }
}
