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

  var body: some Scene {
    WindowGroup {
      MainView()
        .environmentObject(dataStore)
    }
  }
}
