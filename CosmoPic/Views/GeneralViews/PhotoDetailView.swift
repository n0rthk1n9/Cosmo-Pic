//
//  PhotoDetailView.swift
//  CosmoPic
//
//  Created by Jan Armbrust on 27.11.23.
//

import SwiftUI

struct PhotoDetailView: View {
  @EnvironmentObject var favoritesViewModel: FavoritesViewModel
  @StateObject private var viewModel = PhotoDetailViewModel()
  @State private var isCurrentPhotoFavorite = false
  @State private var showCheckmark = false
  @State private var showAlert = false

  let photo: Photo

  var body: some View {
    ScrollView {
      VStack(alignment: .leading) {
        Text(photo.title)
          .font(.title)
          .padding(.horizontal)
        if viewModel.isLoading {
          HStack {
            Spacer()
            ProgressView()
              .frame(height: 300)
            Spacer()
          }
        } else if let photo = viewModel.photo {
          DynamicPhotoView(photo: photo)
        }
        HStack {
          Spacer()
          if showCheckmark {
            CheckmarkView(showCheckmark: $showCheckmark)
          } else if !isCurrentPhotoFavorite {
            FavoriteButtonView(
              photo: photo,
              isCurrentPhotoFavorite: $isCurrentPhotoFavorite,
              showCheckmark: $showCheckmark
            )
          }
          Spacer()
        }
        Text(photo.explanation)
          .padding()
          .accessibilityIdentifier("photo-detail-view-photo-explanation")
      }
    }
    .task {
      await viewModel.getPhoto(for: photo.date)
      checkAndPrepareErrorAlert()
      checkIfFavorite()
    }
    .onAppear {
      favoritesViewModel.loadFavorites()
    }
    .alert(isPresented: $showAlert) {
      Alert(
        title: Text("Error"),
        message: Text(viewModel.error?.localizedDescription ?? "An unknown error occurred"),
        dismissButton: .default(Text("Ok"))
      )
    }
    .navigationTitle(localizedDateString(from: photo.date))
  }

  func checkIfFavorite() {
    if let currentPhoto = viewModel.photo {
      isCurrentPhotoFavorite = favoritesViewModel.isFavorite(currentPhoto)
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

  func checkAndPrepareErrorAlert() {
    if let urlError = viewModel.error as? URLError, urlError.code == .cancelled {
      showAlert = false
    } else if viewModel.error != nil {
      showAlert = true
    }
  }
}
