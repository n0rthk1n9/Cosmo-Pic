//
//  APODView.swift
//  CosmoPic
//
//  Created by Jan Armbrust on 24.11.23.
//

import SwiftUI

struct APODView: View {
  @EnvironmentObject var dataStore: DataStore
  @StateObject var dataStoreNew = DataStoreNew()
  @State private var isCurrentPhotoFavorite = false
  @State private var showCheckmark = false

  var body: some View {
    NavigationStack {
      VStack {
        if !dataStoreNew.isLoading {
          if let localFilename = dataStoreNew.photo?.localFilename {
            let localFileURL = dataStoreNew.getLocalFileURL(forFilename: localFilename)
            PhotoView(url: localFileURL)
          } else {
            if let hdUrl = dataStoreNew.photo?.hdURL {
              PhotoView(url: hdUrl)
            }
          }
        } else {
          ProgressView()
        }
        if !dataStoreNew.isLoading {
          if let photoTitle = dataStoreNew.photo?.title {
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
        }
      }
      .navigationTitle("Cosmo Pic")
    }
    .task {
      guard dataStore.photo == nil else { return }
      let dateFormatter = DateFormatter()
      dateFormatter.dateFormat = "yyyy-MM-dd"
      let currentDate = dateFormatter.string(from: Date())
      await dataStoreNew.getPhoto(for: currentDate)
    }
    .onAppear {
      dataStore.loadFavorites()
    }
    .alert(
      "Something went wrong...",
      isPresented: $dataStoreNew.errorIsPresented,
      presenting: dataStoreNew.error,
      actions: { _ in
        Button("Ok", action: {})
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
