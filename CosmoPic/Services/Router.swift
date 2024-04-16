//
//  Router.swift
//  CosmoPic
//
//  Created by Jan Armbrust on 14.04.24.
//

import SwiftUI

class Router: ObservableObject {
  @Published var path = NavigationPath()
  @Published var activeTab: Tab = .today

  func resetActiveTab() {
    activeTab = .today
  }

  func resetPath() {
    path = NavigationPath()
  }

  static var shared: Router = .init()
}
