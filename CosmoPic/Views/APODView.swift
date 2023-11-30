//
//  APODView.swift
//  CosmoPic
//
//  Created by Jan Armbrust on 24.11.23.
//

import SwiftUI

struct APODView: View {
  @EnvironmentObject var dataStore: DataStore
  @State private var isCurrentPhotoFavorite = false
  @State private var showCheckmark = false

  var body: some View {
    NavigationStack {
      VStack {
        if !dataStore.isLoading {
          if let localFilename = dataStore.photo?.localFilename {
            let localFileURL = FileManager.localFileURL(for: localFilename)
            PhotoView(url: localFileURL)
              .accessibilityIdentifier("apod-view-photo")
          } else {
            if let hdUrl = dataStore.photo?.hdURL {
              PhotoView(url: hdUrl)
                .accessibilityIdentifier("apod-view-photo")
            }
          }
        } else {
          ProgressView()
        }
        if !dataStore.isLoading {
          if let photoTitle = dataStore.photo?.title {
            Text(photoTitle)
              .padding([.top, .trailing, .leading])
              .font(.title2)
          }
        } else {
          EmptyView()
        }
        if showCheckmark {
          Image(systemName: "checkmark.circle.fill")
            .font(.title)
            .foregroundStyle(.green)
            .padding(.top)
            .transition(.opacity)
            .onAppear {
              Task {
                try await Task.sleep(nanoseconds: 1_000_000_000)
                withAnimation {
                  showCheckmark = false
                }
              }
            }
        } else if let photo = dataStore.photo, !isCurrentPhotoFavorite {
          Button("Add to Favorites") {
            addToFavorites(photo)
          }
          .buttonStyle(.bordered)
          .padding(.top)
          .accessibilityIdentifier("apod-view-favorites-button")
        }
      }
      .navigationTitle("Cosmo Pic")
    }
    .task {
      let dateFormatter = DateFormatter()
      dateFormatter.dateFormat = "yyyy-MM-dd"
      let currentDate = dateFormatter.string(from: Date())
      await dataStore.getPhoto(for: currentDate)
      checkIfFavorite()
    }
    .onAppear {
      dataStore.loadFavorites()
    }
    .alert(isPresented: $dataStore.errorIsPresented) {
      if case .photoForTodayNotAvailableYet = dataStore.error as? FetchPhotoError {
        return Alert(
          title: Text("Photo Not Available"),
          message: Text(dataStore.error?
            .localizedDescription ?? "The photo for today is not available yet, do you want to load yesterdays photo?"),
          primaryButton: .default(Text("Load Yesterday's Photo")) {
            loadYesterdayPhoto()
          },
          secondaryButton: .cancel()
        )
      } else {
        return Alert(
          title: Text("Error"),
          message: Text(dataStore.error?.localizedDescription ?? "An unknown error occurred"),
          dismissButton: .default(Text("Ok"))
        )
      }
    }
  }

  func addToFavorites(_ photo: Photo) {
    dataStore.addToFavorites(photo)
    withAnimation {
      showCheckmark = true
      isCurrentPhotoFavorite = true
    }
  }

  func checkIfFavorite() {
    if let currentPhoto = dataStore.photo {
      isCurrentPhotoFavorite = dataStore.isFavorite(currentPhoto)
    }
  }

  func loadYesterdayPhoto() {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    guard let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date()) else { return }
    let yesterdayString = dateFormatter.string(from: yesterday)

    Task {
      await dataStore.getPhoto(for: yesterdayString)
    }
  }
}
