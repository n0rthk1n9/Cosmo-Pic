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
      AsyncImage(url: dataStore.photo?.hdURL) { image in
        image
          .resizable()
          .aspectRatio(contentMode: .fit)
      } placeholder: {
        ProgressView()
      }
      .cornerRadius(20)
      .clipped()
      .padding(.horizontal)
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
      Text(photo.explanation)
        .padding()
    }
    .task {
      await fetchPhoto()
    }
    .onAppear {
      dataStore.loadFavorites()
    }
    .navigationTitle(photo.title)
  }

  func fetchPhoto() async {
    do {
      try await dataStore.getPhoto(for: photo.date)
      Task { @MainActor in
        checkIfFavorite()
      }
    } catch {
      print(error.localizedDescription)
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
}

#Preview {
  PhotoDetailView(photo: Photo(
    copyright: "Bubu",
    date: "2023-11-24",
    explanation: "Test",
    hdURL: URL(string: "https://apod.nasa.gov/apod/image/1709/InsideSaturnsRings_Cassini_1280.gif"),
    mediaType: "image",
    serviceVersion: "v1",
    title: "Test",
    sdURL: URL(string: "https://apod.nasa.gov/apod/image/1709/InsideSaturnsRings_Cassini_1280.gif")
  ))
}
