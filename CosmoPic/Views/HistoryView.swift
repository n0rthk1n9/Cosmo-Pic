//
//  HistoryView.swift
//  CosmoPic
//
//  Created by Jan Armbrust on 24.11.23.
//

import SwiftUI

struct HistoryView: View {
  @EnvironmentObject var dataStoreNew: DataStoreNew
  @State private var isLoading = false

  private var sortedHistory: [Photo] {
    dataStoreNew.history.sorted { $0.date > $1.date }
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
                  .frame(height: 25)
                  .frame(minWidth: 50)
              } placeholder: {
                ProgressView()
                  .frame(minWidth: 50)
              }
              .padding(.trailing)
            } else {
              AsyncImage(url: photo.hdURL) { image in
                image
                  .resizable()
                  .aspectRatio(contentMode: .fit)
                  .frame(height: 25)
                  .frame(minWidth: 50)
              } placeholder: {
                ProgressView()
                  .frame(minWidth: 50)
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
