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
    .alert(
      "Something went wrong...",
      isPresented: $dataStore.errorIsPresented,
      presenting: dataStore.error,
      actions: { _ in
        Button("Ok") {}
      },
      message: { error in
        Text(error.localizedDescription)
      }
    )
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
}

// #Preview {
//  APODView()
// }
