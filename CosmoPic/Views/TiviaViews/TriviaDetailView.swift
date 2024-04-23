//
//  TriviaDetailView.swift
//  CosmoPic
//
//  Created by Jan Armbrust on 23.04.24.
//

import SwiftUI

struct TriviaDetailView: View {
  var planet: TriviaItem
  var allPlanets: [TriviaItem]

  var body: some View {
    ScrollView {
      VStack(alignment: .center) {
        planetImage
      }
      VStack(alignment: .leading, spacing: 20) {
        planetMainDetails
        additionalDetails
        SizeComparisonView(selectedPlanet: planet, planets: allPlanets)
      }
      .padding()
    }
    .navigationTitle(planet.englishName)
    .navigationBarTitleDisplayMode(.inline)
  }

  var planetImage: some View {
    Image(planet.englishName.lowercased())
      .resizable()
      .aspectRatio(contentMode: .fit)
      .frame(height: 300)
      .clipShape(RoundedRectangle(cornerRadius: 5))
  }

  var planetMainDetails: some View {
    VStack(alignment: .leading) {
      Text(planet.englishName)
        .font(.largeTitle)
        .fontWeight(.bold)
      HStack(alignment: .firstTextBaseline, spacing: 0) {
        Text("Mass: \(planet.mass.massValue, specifier: "%.3f") x 10")
        Text("\(planet.mass.massExponent)")
          .font(.system(size: 8))
          .baselineOffset(8)
      }
      HStack(alignment: .firstTextBaseline, spacing: 0) {
        Text("Volume: \(planet.vol.volValue, specifier: "%.3f") x 10")
        Text("\(planet.vol.volExponent)")
          .font(.system(size: 8))
          .baselineOffset(8)
      }
    }
  }

  var additionalDetails: some View {
    DisclosureGroup("Orbital and Rotation Details") {
      VStack(alignment: .leading) {
        Text("Semi-major Axis: \(planet.semimajorAxis, specifier: "%.1f") km")
        Text("Perihelion: \(planet.perihelion, specifier: "%.1f") km")
        Text("Aphelion: \(planet.aphelion, specifier: "%.1f") km")
        Text("Orbital Period: \(planet.sideralOrbit, specifier: "%.2f") days")
        Text("Rotational Period: \(planet.sideralRotation, specifier: "%.2f") hours")
      }
    }
  }
}

// #Preview {
//  TriviaDetailView(planet: TriviaItem.allProperties)
// }
