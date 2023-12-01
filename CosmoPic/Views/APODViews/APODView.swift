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
        if dataStore.isLoading {
          ProgressView()
        } else if let photo = dataStore.photo {
          APODContentView(
            photo: photo,
            isCurrentPhotoFavorite: $isCurrentPhotoFavorite,
            showCheckmark: $showCheckmark
          )
        } else {
          if dataStore.errorIsPresented {
            ContentUnavailableView("No Data available", systemImage: "x.circle")
          }
        }
      }
      .navigationTitle("Cosmo Pic")
      .onAppear(perform: onAppear)
      .task {
        await initialFetch()
      }
      .alert(isPresented: $dataStore.errorIsPresented, content: errorAlert)
    }
  }

  func onAppear() {
    dataStore.resetPhoto()
    dataStore.loadFavorites()
  }

  func initialFetch() async {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    let currentDate = dateFormatter.string(from: Date())
    await dataStore.getPhoto(for: currentDate)
    checkIfFavorite()
  }

  func errorAlert() -> Alert {
    if case .photoForTodayNotAvailableYet = dataStore.error as? FetchPhotoError {
      return Alert(
        title: Text("Photo Not Available"),
        message: Text(dataStore.error?
          .localizedDescription ??
          "The photo for today is not available yet, do you want to load yesterday's photo?"),
        primaryButton: .default(Text("Load Yesterday's Photo"), action: loadYesterdayPhoto),
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
