//
//  TodayView.swift
//  CosmoPic
//
//  Created by Jan Armbrust on 24.11.23.
//

import SwiftUI

struct TodayView: View {
  @StateObject private var viewModel = TodayViewModel()

  var body: some View {
    NavigationStack {
      VStack {
        Spacer()
        if viewModel.isLoading {
          ProgressView()
        } else if let photo = viewModel.photo {
          PhotoDetailContentView(photo: photo)
        } else {
          ContentUnavailableView("No Data available", systemImage: "x.circle")
            .showCustomAlert(alert: $viewModel.error)
        }
        Spacer()
      }
      #if os(visionOS)
      .padding()
      #endif
      .navigationTitle("Cosmo Pic")
      .task {
        await viewModel.fetchPhotoForToday()
      }
    }
  }
}

#Preview {
  TodayView()
    .environmentObject(FavoritesViewModel())
}
