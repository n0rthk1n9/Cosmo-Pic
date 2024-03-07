//
//  PurchaseStatusPublisher.swift
//  CosmoPic
//
//  Created by Jan Armbrust on 07.03.24.
//

import Foundation

class PurchaseStatusPublisher: ObservableObject {
  static let shared = PurchaseStatusPublisher()

  @Published var purchaseMade = false

  @MainActor
  func setPurchaseMade(_ value: Bool) {
    purchaseMade = value
  }
}
