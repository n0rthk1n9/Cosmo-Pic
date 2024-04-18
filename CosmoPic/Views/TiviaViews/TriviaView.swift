//
//  TriviaView.swift
//  CosmoPic
//
//  Created by Jan Armbrust on 18.04.24.
//

import SwiftUI

struct TriviaView: View {
  @State private var viewModel = TriviaViewModel()

  var body: some View {
    NavigationStack {
      VStack {
        if viewModel.isLoading {
          ProgressView()
        } else if viewModel.planets.isNotEmpty {
          List(viewModel.planets, id: \.englishName) { planet in
            NavigationLink(value: planet) {
              Text(planet.englishName)
            }
          }
        }
      }
      .navigationDestination(for: TriviaItem.self) { planet in
        Text(planet.englishName)
      }
      .navigationTitle("Planets 🪐")
    }
    .task {
      await viewModel.getPlanets()
    }
  }
}

#Preview {
  TriviaView()
}
