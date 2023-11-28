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
  @State private var showAlert = false
  @State private var alertMessage = ""

  var body: some View {
    NavigationStack {
      VStack {
        AsyncImage(url: getLocalFileURLOrDefault(for: dataStore.photo)) { image in
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
    .alert(isPresented: $showAlert) {
      Alert(
        title: Text("Data Unavailable"),
        message: Text(alertMessage),
        primaryButton: .default(Text("Try Previous Day")) {
          Task {
            await loadPreviousDayImage()
          }
        },
        secondaryButton: .cancel()
      )
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
      alertMessage = "No data available for \(currentDate). Would you like to try the previous day?"
      showAlert = true
      print(error.localizedDescription)
    }
  }

  private func loadPreviousDayImage() async {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"

    if let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date()) {
      let yesterdayString = dateFormatter.string(from: yesterday)

      do {
        try await dataStore.getPhoto(for: yesterdayString)
      } catch {
        print("Error loading photo for previous day: \(error.localizedDescription)")
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

  func getLocalFileURLOrDefault(for photo: Photo?) -> URL? {
    guard let photo = photo else {
      return nil
    }

    if let localFilename = photo.localFilename {
      let localFileURL = FileManager.documentsDirectoryURL.appendingPathComponent(localFilename)
      if FileManager.default.fileExists(atPath: localFileURL.path) {
        return localFileURL
      }
    }

    return photo.hdURL
  }
}

#Preview {
  APODView()
}
