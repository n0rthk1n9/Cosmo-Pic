//
//  MainView.swift
//  CosmoPic
//
//  Created by Jan Armbrust on 20.11.23.
//

import SwiftUI

struct MainView: View {
  @AppStorage("WelcomeScreenShown")
  var welcomeScreenShown = false
  @State private var showingWelcomeScreen = false

  var body: some View {
    TabView {
      APODView()
        .tabItem {
          Label("APOD", systemImage: "photo.stack")
        }
      FavoritesView()
        .tabItem {
          Label("Favorites", systemImage: "list.star")
        }
      HistoryView()
        .tabItem {
          Label("History", systemImage: "clock.arrow.circlepath")
        }
    }
    .onAppear {
      if !welcomeScreenShown {
        showingWelcomeScreen = true
      }
    }
    .sheet(
      isPresented: $showingWelcomeScreen,
      onDismiss: {
        welcomeScreenShown = true
      }, content: {
        WelcomeView(isPresented: $showingWelcomeScreen)
      }
    )
  }
}
