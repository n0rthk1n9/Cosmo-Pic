//
//  HistoryView.swift
//  CosmoPic
//
//  Created by Jan Armbrust on 24.11.23.
//

import SwiftUI

struct HistoryView: View {
  @EnvironmentObject var dataStore: DataStore
  @State private var isLoading = false
  @State private var progress = 0.0

  private var sortedHistory: [Photo] {
    dataStore.history.sorted { $0.date > $1.date }
  }

  var body: some View {
    NavigationStack {
      List(sortedHistory, id: \.title) { photo in
        NavigationLink(destination: PhotoDetailView(photo: photo)) {
          HStack(alignment: .top, spacing: 0.0) {
            if let localFilename = photo.localFilename {
              let localFileURL = FileManager.localFileURL(for: localFilename)
              AsyncImage(url: localFileURL) { image in
                image
                  .resizable()
                  .aspectRatio(contentMode: .fit)
                  .frame(height: 30)
                  .frame(minWidth: 60)
              } placeholder: {
                ProgressView()
                  .frame(minWidth: 60)
              }
              .padding(.trailing)
            } else {
              AsyncImage(url: photo.hdURL) { image in
                image
                  .resizable()
                  .aspectRatio(contentMode: .fit)
                  .frame(height: 30)
                  .frame(minWidth: 60)
              } placeholder: {
                ProgressView()
                  .frame(minWidth: 60)
              }
              .padding(.trailing)
            }
            VStack(alignment: .leading, spacing: 0.0) {
              Text(photo.title)
              Text(photo.copyright ?? "No copyright")
                .font(.caption)
                .foregroundStyle(.gray)
                .padding(.top)
            }
          }
        }
      }
      .navigationTitle("Photo History")
      .overlay {
        if dataStore.isLoading {
          VStack {
            ProgressView()
              .padding(.bottom)
            ProgressView(
              value: Double(dataStore.loadedHistoryElements),
              total: Double(dataStore.totalHistoryElements)
            )
            .padding(.bottom)
            Text("\(dataStore.loadedHistoryElements) / \(dataStore.totalHistoryElements)")
          }
          .padding()
        }
      }
      .task {
        await dataStore.getHistory()
      }
      .accessibilityIdentifier("history-list")
    }
  }
}

// #Preview {
//  HistoryView()
// }
