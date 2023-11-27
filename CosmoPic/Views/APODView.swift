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
        Text(dataStore.photo?.title ?? "")
          .padding([.top, .trailing, .leading])
          .font(.title2)
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
      await fetchPhoto()
    }
    .onAppear {
      dataStore.loadFavorites()
    }
  }

  func fetchPhoto() async {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    let currentDate = dateFormatter.string(from: Date())

    do {
      try await dataStore.getPhoto(for: currentDate)
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
  APODView()
}
