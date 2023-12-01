//
//  PhotoDetailView.swift
//  CosmoPic
//
//  Created by Jan Armbrust on 27.11.23.
//

import SwiftUI

struct PhotoDetailView: View {
  @EnvironmentObject var dataStore: DataStore
  @State private var isCurrentPhotoFavorite = false
  @State private var showCheckmark = false
  let photo: Photo

  var body: some View {
    ScrollView {
      VStack(alignment: .leading) {
        Text(photo.title)
          .font(.title)
          .padding(.horizontal)
        if !dataStore.isLoading {
          if let localFilename = dataStore.photo?.localFilename {
            let localFileURL = FileManager.localFileURL(for: localFilename)
            PhotoView(url: localFileURL)
          } else {
            if let hdUrl = dataStore.photo?.hdURL {
              PhotoView(url: hdUrl)
            }
          }
        } else {
          HStack {
            Spacer()
            ProgressView()
            Spacer()
          }
        }
        HStack {
          Spacer()
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
          Spacer()
        }

        if !dataStore.isLoading {
          if let photoExplanation = dataStore.photo?.explanation {
            Text(photoExplanation)
              .padding()
              .accessibilityIdentifier("photo-detail-view-photo-explanation")
          }
        } else {
          EmptyView()
        }
      }
    }
    .task {
      await dataStore.getPhoto(for: photo.date)
      checkIfFavorite()
    }
    .onAppear {
      dataStore.resetPhoto()
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
    .navigationTitle(localizedDateString(from: photo.date))
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

  func localizedDateString(from dateString: String) -> String {
    let inputFormatter = DateFormatter()
    inputFormatter.dateFormat = "yyyy-MM-dd"
    inputFormatter.locale = Locale(identifier: "en_US_POSIX")

    let outputFormatter = DateFormatter()
    outputFormatter.dateStyle = .medium
    outputFormatter.timeStyle = .none
    outputFormatter.locale = Locale.current

    if let date = inputFormatter.date(from: dateString) {
      return outputFormatter.string(from: date)
    } else {
      return "Invalid Date"
    }
  }
}
