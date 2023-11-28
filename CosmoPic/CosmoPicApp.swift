//
//  CosmoPicApp.swift
//  CosmoPic
//
//  Created by Jan Armbrust on 20.11.23.
//

import SwiftUI

@main
struct CosmoPicApp: App {
  @StateObject var dataStoreNew = DataStoreNew()

  var body: some Scene {
    WindowGroup {
      MainView()
        .environmentObject(dataStoreNew)
    }
  }
}
