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
          List {
            ForEach(viewModel.planets, id: \.englishName) { planet in
              NavigationLink(value: planet) {
                PlanetRowView(planet: planet)
              }
              .listRowSeparator(.hidden)
              .listRowInsets(.init(top: 10, leading: 20, bottom: 0, trailing: 20))
            }
          }
          .listStyle(.plain)
        }
      }
      .navigationDestination(for: TriviaItem.self) { planet in
        TriviaDetailView(planet: planet, allPlanets: viewModel.planets)
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
