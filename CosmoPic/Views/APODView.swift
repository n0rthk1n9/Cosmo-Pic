//
//  APODView.swift
//  CosmoPic
//
//  Created by Jan Armbrust on 24.11.23.
//

import SwiftUI

struct APODView: View {
  @EnvironmentObject var dataStore: DataStore

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
      Text(dataStore.photo?.title ?? "")
        .task {
          await fetchPhoto()
        }
    }
  }

  func fetchPhoto() async {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    let currentDate = dateFormatter.string(from: Date())

    do {
      try await dataStore.getPhoto(for: currentDate)
    } catch {
      print(error.localizedDescription)
    }
  }
}

#Preview {
  APODView()
}
