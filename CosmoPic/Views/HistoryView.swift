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

  private var sortedHistory: [Photo] {
    dataStore.history.sorted { $0.date > $1.date }
  }

  var body: some View {
    NavigationStack {
      List(sortedHistory, id: \.title) { photo in
        NavigationLink(destination: HistoryDetailView(photo: photo)) {
          Text(photo.title)
        }
      }
      .navigationTitle("Photo History")
      .overlay {
        if isLoading {
          ProgressView()
        }
      }
      .task {
        await loadHistory()
      }
    }
  }

  private func loadHistory() async {
    isLoading = true
    do {
      try await dataStore.fetchHistory()
    } catch {
      print("Error fetching history: \(error.localizedDescription)")
      // Handle the error appropriately here
    }
    isLoading = false
  }
}

#Preview {
  HistoryView()
}
