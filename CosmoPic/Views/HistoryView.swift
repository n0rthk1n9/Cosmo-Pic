//
//  HistoryView.swift
//  CosmoPic
//
//  Created by Jan Armbrust on 24.11.23.
//

import SwiftUI

struct HistoryView: View {
  @EnvironmentObject var dataStore: DataStore
  @StateObject var dataStoreNew = DataStoreNew()
  @State private var isLoading = false

  private var sortedHistory: [Photo] {
    dataStoreNew.history.sorted { $0.date > $1.date }
  }

  var body: some View {
    NavigationStack {
      List(sortedHistory, id: \.title) { photo in
        NavigationLink(destination: PhotoDetailView(photo: photo)) {
          HStack {
            if let localFilename = photo.localFilename {
              let localURL = FileManager.localFileURL(for: localFilename)
              AsyncImage(url: localURL) { image in
                image
                  .resizable()
                  .aspectRatio(contentMode: .fit)
                  .frame(height: 25)
              } placeholder: {
                ProgressView()
              }
            } else {
              AsyncImage(url: photo.hdURL) { image in
                image
                  .resizable()
                  .aspectRatio(contentMode: .fit)
                  .frame(height: 25)
              } placeholder: {
                ProgressView()
              }
            }
            Text(photo.title)
          }
        }
      }
      .navigationTitle("Photo History")
      .overlay {
        if dataStoreNew.isLoading {
          ProgressView()
        }
      }
      .task {
        await dataStoreNew.getHistory()
      }
    }
  }
}

// #Preview {
//  HistoryView()
// }
