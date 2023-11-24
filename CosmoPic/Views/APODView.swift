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
    Text(dataStore.photo?.title ?? "")
      .task {
        await fetchPhoto()
      }
  }

  func fetchPhoto() async {
    do {
      try await dataStore.fetchPhoto(for: "2023-11-23")
    } catch {
      print(error.localizedDescription)
    }
  }
}

#Preview {
  APODView()
}
