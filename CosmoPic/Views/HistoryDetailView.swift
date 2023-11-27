//
//  HistoryDetailView.swift
//  CosmoPic
//
//  Created by Jan Armbrust on 27.11.23.
//

import SwiftUI

struct HistoryDetailView: View {
  @EnvironmentObject var dataStore: DataStore
  let photo: Photo

  var body: some View {
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
      Text(photo.title)
        .task {
          await fetchPhoto()
        }
    }
    .navigationTitle("Detail")
  }

  func fetchPhoto() async {
    do {
      try await dataStore.getPhoto(for: photo.date)
    } catch {
      print(error.localizedDescription)
    }
  }
}

#Preview {
  HistoryDetailView(photo: Photo(
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
