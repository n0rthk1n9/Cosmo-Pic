//
//  DateFormatter.swift
//  CosmoPic
//
//  Created by Jan Armbrust on 07.02.24.
//

import Foundation

public extension DateFormatter {
  static let yyyyMMdd: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    return formatter
  }()
}
