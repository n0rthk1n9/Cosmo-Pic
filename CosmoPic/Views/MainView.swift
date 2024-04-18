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
  @EnvironmentObject private var router: Router
  @State private var showingWelcomeScreen = false

  var body: some View {
    TabView(selection: $router.activeTab) {
      TodayView()
        .tag(Tab.today)
        .tabItem {
          Label(Tab.today.rawValue, systemImage: Tab.today.tabSymbol)
        }
      FavoritesView()
        .tag(Tab.favorites)
        .tabItem {
          Label(Tab.favorites.rawValue, systemImage: Tab.favorites.tabSymbol)
        }
      HistoryView()
        .tag(Tab.history)
        .tabItem {
          Label(Tab.history.rawValue, systemImage: Tab.history.tabSymbol)
        }
      TriviaView()
        .tag(Tab.trivia)
        .tabItem {
          Label(Tab.trivia.rawValue, systemImage: Tab.trivia.tabSymbol)
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

#Preview {
  MainView()
    .environmentObject(FavoritesViewModel())
    .environmentObject(Router())
}
