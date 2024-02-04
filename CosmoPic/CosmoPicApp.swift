//
//  CosmoPicApp.swift
//  CosmoPic
//
//  Created by Jan Armbrust on 20.11.23.
//

import SwiftUI

@main
struct CosmoPicApp: App {
  @StateObject var dataStore = DataStore()
  @StateObject var favoritesViewModel = FavoritesViewModel()

  init() {
    if ProcessInfo.processInfo.arguments.contains("UITesting") {
      UserDefaults.standard.set(false, forKey: "WelcomeScreenShown")
    }
  }

  var body: some Scene {
    WindowGroup {
      MainView()
        .environmentObject(dataStore)
        .environmentObject(favoritesViewModel)
    }
  }
}
