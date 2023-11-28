//
//  PhotoDetailView.swift
//  CosmoPic
//
//  Created by Jan Armbrust on 27.11.23.
//

import SwiftUI

struct PhotoDetailView: View {
  @EnvironmentObject var dataStoreNew: DataStoreNew
  @State private var isCurrentPhotoFavorite = false
  @State private var showCheckmark = false
  let photo: Photo

  var body: some View {
    ScrollView {
      if !dataStoreNew.isLoading {
        if let localFilename = dataStoreNew.photo?.localFilename {
          let localFileURL = FileManager.localFileURL(for: localFilename)
          PhotoView(url: localFileURL)
        } else {
          if let hdUrl = dataStoreNew.photo?.hdURL {
            PhotoView(url: hdUrl)
          }
        }
      } else {
        ProgressView()
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
      } else if let photo = dataStoreNew.photo, !isCurrentPhotoFavorite {
        Button("Add to Favorites") {
          addToFavorites(photo)
        }
        .buttonStyle(.bordered)
        .padding(.top)
      }
      if !dataStoreNew.isLoading {
        if let photoExplanation = dataStoreNew.photo?.explanation {
          Text(photoExplanation)
            .padding()
        }
      } else {
        EmptyView()
      }
    }
    .task {
      await dataStoreNew.getPhoto(for: photo.date)
      checkIfFavorite()
    }
    .onAppear {
      dataStoreNew.loadFavorites()
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
    .navigationTitle(photo.title)
  }

  func addToFavorites(_ photo: Photo) {
    dataStoreNew.addToFavorites(photo)
    withAnimation {
      showCheckmark = true
      isCurrentPhotoFavorite = true
    }
  }

  func checkIfFavorite() {
    if let currentPhoto = dataStoreNew.photo {
      isCurrentPhotoFavorite = dataStoreNew.isFavorite(currentPhoto)
    }
  }
}

// #Preview {
//  PhotoDetailView(photo: Photo(
//    copyright: "Bubu",
//    date: "2023-11-24",
//    explanation: "Test",
//    hdURL: URL(string: "https://apod.nasa.gov/apod/image/1709/InsideSaturnsRings_Cassini_1280.gif"),
//    mediaType: "image",
//    serviceVersion: "v1",
//    title: "Test",
//    sdURL: URL(string: "https://apod.nasa.gov/apod/image/1709/InsideSaturnsRings_Cassini_1280.gif")
//  ))
// }
