//
//  Router.swift
//  CosmoPic
//
//  Created by Jan Armbrust on 14.04.24.
//

import SwiftUI

class Router: ObservableObject {
  @Published var activeTab: Tab = .today

  func resetActiveTab() {
    activeTab = .today
  }

  static var shared: Router = .init()
}
