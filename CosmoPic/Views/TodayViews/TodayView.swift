//
//  TodayView.swift
//  CosmoPic
//
//  Created by Jan Armbrust on 24.11.23.
//

import SwiftUI

struct TodayView: View {
  @StateObject private var viewModel = TodayViewModel()

  @State private var photoZoomableSheetIsShown = false

  var body: some View {
    NavigationStack {
      VStack {
        Spacer()
        if viewModel.isLoading {
          ProgressView()
        } else if let photo = viewModel.photo {
          TodayPhotoView(photo: photo, isDescriptionShowing: viewModel.isDescriptionShowing) {
            Task { @MainActor in
              withAnimation {
                viewModel.isDescriptionShowing.toggle()
              }
            }
          }
          .animation(.easeIn, value: viewModel.isDescriptionShowing)
          .sheet(
            isPresented: $photoZoomableSheetIsShown,
            content: {
              PhotoZoomableView(photo: photo)
                .presentationBackground(.ultraThinMaterial)
                .presentationCornerRadius(16)
            }
          )
          .onTapGesture {
            photoZoomableSheetIsShown.toggle()
          }
        } else {
          ContentUnavailableView(
            label: {
              Label("No photo downloaded", systemImage: "photo.fill")
            }, description: {
              Text(
                """
                Sorry, we were not able to get you your daily dose of space!
                Come back later or try again with the button below
                """
              )
            }, actions: {
              Button(
                action: {
                  Task {
                    await viewModel.fetchPhotoForToday()
                  }
                },
                label: {
                  Image(systemName: "arrow.clockwise")
                }
              )
            }
          )
          .showCustomAlert(alert: $viewModel.error)
        }
        Spacer()
      }
      #if os(visionOS)
      .padding()
      #endif
      .navigationTitle("Today 🗓️")
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
