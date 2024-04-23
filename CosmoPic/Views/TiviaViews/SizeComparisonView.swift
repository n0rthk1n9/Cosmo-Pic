//
//  SizeComparisonView.swift
//  CosmoPic
//
//  Created by Jan Armbrust on 23.04.24.
//

import Foundation
import SwiftUI

struct SizeComparisonView: View {
  var selectedPlanet: TriviaItem
  var planets: [TriviaItem]

  @State private var scale: Double = 0.5

  var body: some View {
    VStack {
      Text("Size Comparison")
        .font(.headline)
      sizeComparisonScrollView()
      Slider(value: $scale, in: 0.1 ... 1.0, step: 0.01)
        .padding()
      Text("Scale: \(scale, specifier: "%.1f")x")
    }
    .padding()
  }

  private func sizeComparisonScrollView() -> some View {
    ScrollView(.horizontal, showsIndicators: false) {
      ScrollViewReader { value in
        HStack(alignment: .center, spacing: 20) {
          ForEach(planets, id: \.englishName) { planet in
            VStack {
              Text(planet.englishName)
                .foregroundColor(Color.primary)
                .font(.caption)
                .padding(.bottom, 2)
              Circle()
                .fill(colorForPlanet(named: planet.englishName))
                .frame(width: scaledRadius(for: planet), height: scaledRadius(for: planet))
                .id(planet.englishName)
            }
          }
        }
        .onAppear {
          withAnimation {
            value.scrollTo(selectedPlanet.englishName, anchor: .center)
          }
        }
      }
    }
    .frame(height: 200)
  }

  private func scaledRadius(for planet: TriviaItem) -> CGFloat {
    let baseRadius = CGFloat(planet.meanRadius / selectedPlanet.meanRadius)
    let logarithmicRadius = log(baseRadius + 1)
    let normalizedRadius = logarithmicRadius * CGFloat(scale * 50)
    return max(normalizedRadius, 10)
  }

  private func colorForPlanet(named name: String) -> Color {
    switch name.lowercased() {
    case "mercury":
      return Color.gray
    case "venus":
      return Color.yellow
    case "earth":
      return Color.blue
    case "mars":
      return Color.red
    case "jupiter":
      return Color.orange
    case "saturn":
      return Color.yellow.opacity(0.7)
    case "uranus":
      return Color.cyan
    case "neptune":
      return Color.blue.opacity(0.7)
    default:
      return Color.gray.opacity(0.5) // Default color if none match
    }
  }
}

// #Preview {
//  SizeComparisonView()
// }
