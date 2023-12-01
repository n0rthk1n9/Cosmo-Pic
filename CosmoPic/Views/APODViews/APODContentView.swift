//
//  APODContentView.swift
//  CosmoPic
//
//  Created by Jan Armbrust on 01.12.23.
//

import SwiftUI

struct APODContentView: View {
  let photo: Photo
  @Binding var isCurrentPhotoFavorite: Bool
  @Binding var showCheckmark: Bool
  @EnvironmentObject var dataStore: DataStore

  var body: some View {
    VStack {
      Text(localizedDateString(from: photo.date))
        .font(.largeTitle)

      DynamicPhotoView(photo: photo)
        .accessibilityIdentifier("apod-view-photo")

      Text(photo.title)
        .padding([.top, .trailing, .leading])
        .font(.title2)

      if showCheckmark {
        CheckmarkView(showCheckmark: $showCheckmark)
      } else if !isCurrentPhotoFavorite {
        FavoriteButtonView(
          photo: photo,
          isCurrentPhotoFavorite: $isCurrentPhotoFavorite,
          showCheckmark: $showCheckmark
        )
        .accessibilityIdentifier("apod-view-favorites-button")
      }
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
